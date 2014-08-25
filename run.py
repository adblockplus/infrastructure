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
Usage: %s [-u <user>] [-h <host>|<group>] [-i] ... <command>

Runs a command on the given hosts or groups of hosts.

Options:
  -u <user>       User name to use with the SSH command
  -h <host|group> Host or group to run the command on (can be specified multiple times)
  -i              If specified, command will be executed on all hosts despite errors
''' % sys.argv[0]

def parseOptions(args):
  try:
    options, args = getopt.getopt(args, 'u:h:i')
  except getopt.GetoptError, e:
    print >>sys.stderr, e
    usage()
    sys.exit(1)

  user = None
  hosts = []
  ignore_errors = False
  for option, value in options:
    if option == '-u':
      user = value
    elif option == '-h':
      hosts.append(value)
    elif option == '-i':
      ignore_errors = True

  return user, hosts, ignore_errors, args

def readMonitoringConfig():
  # Use Puppet's parser to convert monitoringserver.pp into YAML
  manifest = os.path.join(os.path.dirname(__file__), 'manifests', 'monitoringserver.pp')
  parseScript = '''
    require 'puppet'
    require 'puppet/parser'
    parser = Puppet::Parser::Parser.new(Puppet[:environment])
    Puppet.settings[:ignoreimport] = true
    parser.file = ARGV[0]
    print ZAML.dump(parser.parse)
  '''
  data, dummy = subprocess.Popen(['ruby', '', manifest],
                  stdin=subprocess.PIPE,
                  stdout=subprocess.PIPE).communicate(parseScript)

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

  monitoringConfig = readMonitoringConfig()
  if not monitoringConfig:
    print >>sys.stderr, "Failed to parse monitoring configuration"
    return [[], []]
  # Extract hosts and groups from monitoring config
  return processNode(monitoringConfig)

def resolveHostList(hosts):
  validHosts, validGroups = getValidHosts()
  if not validHosts:
    print >>sys.stderr, "Warning: No valid hosts found, not validating"
    return hosts

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

def runCommand(user, host, command, ignore_errors=False):
  if not isinstance(command, list):
    command = [command]
  command = ["ssh"] + (["-l", user] if user else []) + [host] + command
  if ignore_errors:
    subprocess.call(command)
  else:
    subprocess.check_call(command)

if __name__ == "__main__":
  user, hosts, ignore_errors, args = parseOptions(sys.argv[1:])
  selectedHosts = resolveHostList(hosts)
  if len(selectedHosts) == 0:
    print >>sys.stderr, 'No valid hosts or groups specified, nothing to do'
    sys.exit(0)
  for host in selectedHosts:
    print >>sys.stderr, 'Running on %s...' % host
    runCommand(user, host, args, ignore_errors=ignore_errors)
