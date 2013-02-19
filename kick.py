#!/usr/bin/env python
# coding: utf-8

import sys
import os
import re
import subprocess
import getopt
import yaml

def usage():
  print >>sys.stderr, '''
Usage: %s -u <user> [-t|-q] [<host>|<group>] ...

Runs provisioning on the given hosts or groups of hosts.

Options:
  -u <user>       User name to use with the SSH command (needs access to puppet
                  master and all hosts)
  -t              Dry-run mode, will produce the usual output but not change
                  host configuration
  -q              Quiet mode, suppress Puppet output to console
''' % sys.argv[0]

def parseOptions(args):
  try:
    options, args = getopt.getopt(args, 'u:vt')
  except getopt.GetoptError, e:
    print >>sys.stderr, e
    usage()
    sys.exit(1)

  if set(('-t', '-q')).issubset(options):
    print >>sys.stderr, 'Only one mode flag can be specified, either -t or -q'
    usage()
    sys.exit(1)

  user = None
  mode = ' --test'
  for option, value in options:
    if option == '-u':
      user = value
    elif option == '-q':
      mode = ''
    elif option == '-t':
      mode = ' --test --noop'

  if user == None:
    print >>sys.stderr, 'No user name specified'
    usage()
    sys.exit(1)

  return user, mode, args

def readMonitoringConfig():
  # Use Puppet's parser to convert monitoringserver.pp into YAML
  manifest = os.path.join(os.path.dirname(__file__), 'manifests', 'monitoringserver.pp')
  parseScript = '''
    require 'puppet/parser'
    parser = Puppet::Parser::Parser.new(Puppet[:environment])
    parser.file = ARGV[0]
    print ZAML.dump(parser.parse)
  '''
  data, dummy = subprocess.Popen(['ruby', '', manifest],
                  stdin=subprocess.PIPE,
                  stdout=subprocess.PIPE,
                  stderr=subprocess.PIPE).communicate(parseScript)

  # See http://stackoverflow.com/q/8357650/785541 on parsing Puppet's YAML
  yaml.add_multi_constructor(u"!ruby/object:", lambda loader, suffix, node: loader.construct_yaml_map(node))
  yaml.add_constructor(u"!ruby/sym", lambda loader, node: loader.construct_yaml_str(node))
  return yaml.load(data)

def getValidHosts():
  def processNode(node, hosts=None, groups=None):
    if hosts == None:
      hosts = set()
    if groups == None:
      groups = {}

    if 'context' in node and 'code' in node['context']:
      node = node['context']['code']

    if node.get('type', None) == 'nagios_hostgroup':
      data = node['instances']['children'][0]
      title = data['title']['value']
      members = filter(lambda c: c['param'] == 'members', data['parameters']['children'])[0]['value']['value']
      members = re.split(r'\s*,\s*', members)
      groups[title] = members
    elif node.get('type', None) == 'nagios_host':
      data = node['instances']['children'][0]
      title = data['title']['value']
      hosts.add(title)

    for child in node['children']:
      processNode(child, hosts, groups)
    return hosts, groups

  # Extract hosts and groups from monitoring config
  return processNode(readMonitoringConfig())

def resolveHostList(hosts, validHosts, validGroups):
  result = set()
  for param in hosts:
    if param in validGroups:
      for host in validGroups[param]:
        if host == '*':
          result = result | validHosts
        else:
          result.add(host)
    elif param in validHosts:
      result.add(param)
    elif '%s.adblockplus.org' % param in validHosts:
      result.add('%s.adblockplus.org' % param)
    else:
      print >>sys.stderr, 'Warning: failed to recognize host or group %s' %param
  return result

def updateMaster(user):
  print 'Updating data on the puppet master...'
  remoteCommand = ' && '.join([
    'sudo hg pull -qu -R /etc/puppet/infrastructure',
    'sudo hg pull -qu -R /etc/puppet/infrastructure/modules/private',
  ])
  os.system('ssh -l %s puppetmaster.adblockplus.org "%s"' % (user, remoteCommand))

def updateClient(user, host, mode):
  print 'Provisioning %s...' % host
  remoteCommand = 'sudo puppet agent%s' %mode
  os.system('ssh -l %s %s "%s"' % (user, host, remoteCommand))

if __name__ == "__main__":
  user, mode, args = parseOptions(sys.argv[1:])
  hosts, groups = getValidHosts()
  needKicking = resolveHostList(args, hosts, groups)
  if len(needKicking) == 0:
    print >>sys.stderr, 'No valid hosts or groups specified, nothing to do'
    sys.exit(0)
  updateMaster(user)
  for host in needKicking:
    updateClient(user, host, mode)
