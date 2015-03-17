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


def getValidHosts():
  dirname = os.path.dirname(sys.argv[0])
  path_name = os.path.join(dirname, "hiera", "private", "hosts.yaml")
  with open(path_name, 'rb') as handle:
    config = yaml.load(handle)
  servers = config.get('servers', {})
  return servers  

def resolveHostList(hosts):

  result = set()

  try:
    valid_hosts = getValidHosts()
  except Warning as error:
    print >>sys.stderr, 'Warning: failed to determine valid hosts:', error
    result.update(hosts)
  else:
    for name in hosts:
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
