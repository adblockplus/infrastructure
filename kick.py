#!/usr/bin/env python
# coding: utf-8

import sys
import getopt
from run import resolveHostList, runCommand

def usage():
  print >>sys.stderr, '''
Usage: %s [-u <user>] [-t|-q] [<host>|<group>] ...

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

  return user, mode, args

def updateMaster(user):
  print 'Updating data on the puppet master...'
  remoteCommand = ' && '.join([
    'sudo hg pull -qu -R /etc/puppet/infrastructure',
    'sudo hg pull -qu -R /etc/puppet/infrastructure/modules/private',
  ])
  runCommand(user, "puppetmaster.adblockplus.org", remoteCommand)

def updateClient(user, host, mode):
  print 'Provisioning %s...' % host
  remoteCommand = 'sudo puppet agent%s' % mode

  # Have to ignore errors here, Puppet will return non-zero for successful runs
  runCommand(user, host, remoteCommand, ignore_errors=True)

if __name__ == "__main__":
  user, mode, args = parseOptions(sys.argv[1:])
  needKicking = resolveHostList(args)
  if len(needKicking) == 0:
    print >>sys.stderr, 'No valid hosts or groups specified, nothing to do'
    sys.exit(0)
  updateMaster(user)
  for host in needKicking:
    updateClient(user, host, mode)
