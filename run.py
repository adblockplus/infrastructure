#!/usr/bin/env python
# coding: utf-8

import argparse
import sys
import os
import posixpath
import re
import subprocess
import yaml

def createArgumentParser(**kwargs):
  parser = argparse.ArgumentParser(**kwargs)
  parser.add_argument(
    '-u', '--user', metavar='user', dest='user', type=str,
    help='user name for use with SSH, must exist on all hosts'
  )

  parser.add_argument(
    '-l', '--local', action='store_false', dest='remote', default=None,
    help='use the local version of hosts.yaml'
  )

  parser.add_argument(
    '-r', '--remote', metavar='master', dest='remote', type=str,
    help='use a remote (puppet-master) version of hosts.yaml'
  )

  return parser

def parseOptions(args):
  description = 'Run a command on the given hosts or groups of hosts'
  parser = createArgumentParser(description=description)
  parser.add_argument(
    '-i', '--ignore-errors', action='store_true', dest='ignore_errors',
    help='continue execution on next host in case of an error'
  )

  hosts = set()
  parser.add_argument(
    '-t', '--target', metavar='host|group',
    help='target host or group, can be specified multiple times',
    type=lambda value: hosts.update([value])
  )

  parser.add_argument(
    'args', metavar='command', type=str, nargs='+',
    help='the command to run on the specified hosts'
  )

  options = parser.parse_args(args)
  options.hosts = hosts
  return options

def getValidHosts(options):
  path_canonical = ('modules', 'private', 'hiera', 'hosts.yaml')

  if options.remote:
    login = ['-l', options.user] if options.user else []
    path_name = posixpath.join('/etc/puppet/infrastructure', *path_canonical)
    command = ['ssh'] + login + [options.remote, '--', 'sudo', 'cat', path_name]
    child = subprocess.Popen(command, stderr=sys.stderr, stdout=subprocess.PIPE)
    try:
      config = yaml.load(child.stdout)
    finally:
      child.stdout.close()
      child.wait()
  elif options.remote is False:
    dirname = os.path.dirname(sys.argv[0])
    path_name = os.path.join(dirname, *path_canonical)
    with open(path_name, 'rb') as handle:
      config = yaml.load(handle)
  else:
    sys.exit('Please either specify a --remote host or use --local')

  servers = config.get('servers', {})
  return servers  

def resolveHostList(options):

  result = set()

  try:
    valid_hosts = getValidHosts(options)
  except Warning as error:
    print >>sys.stderr, 'Warning: failed to determine valid hosts:', error
    result.update(options.hosts)
  else:
    for name in options.hosts:
      chunk = [
          value.get('dns', key) for (key, value) in valid_hosts.items()

          if name == key
          or name == '*'
          or name == value.get('dns', None)
          or name in value.get('groups', ())
      ]

      if len(chunk) == 0:
        print >>sys.stderr, 'Warning: failed to recognize host or group', name
      else:
        result.update(chunk)

  return result

def runCommand(user, host, command, ignore_errors=False):
  if not isinstance(command, list):
    command = [command]
  command = ['ssh'] + (['-l', user] if user else []) + [host] + command
  if ignore_errors:
    subprocess.call(command)
  else:
    subprocess.check_call(command)

if __name__ == '__main__':
  options = parseOptions(sys.argv[1:])
  selectedHosts = resolveHostList(options)
  if len(selectedHosts) == 0:
    print >>sys.stderr, 'No valid hosts or groups specified, nothing to do'
    sys.exit(0)
  for host in selectedHosts:
    print >>sys.stderr, 'Running on %s...' % host
    runCommand(options.user, host, options.args, options.ignore_errors)
