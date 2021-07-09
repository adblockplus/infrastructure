#!/usr/bin/env python
# coding: utf-8

import sys
import getopt
from run import resolveHostList, runCommand, createArgumentParser


def parseOptions(args):
    description = 'Run provisioning on the given hosts or groups of hosts'
    parser = createArgumentParser(description=description)
    parser.add_argument(
        '-t', '--test', action='store_true', dest='dry_run',
        help='dry-run mode, will not apply any host setup changes'
    )

    parser.add_argument(
        '-q', '--quiet', action='store_true', dest='quiet',
        help='quiet mode, suppresses Puppet output to console'
    )

    parser.add_argument(
        '-a', '--tags', metavar='tags', dest='tags', type=str,
        help='restrict catalog, as in puppet agent --tags'
    )

    parser.add_argument(
        'hosts', metavar='host|group', nargs='+',
        help='target host or group, can be specified multiple times',
    )

    options = parser.parse_args(args)

    if options.quiet and options.dry_run:
        print >>sys.stderr, 'Only one mode flag can be specified, either -t or -q'
        sys.exit(1)
    elif options.quiet:
        options.mode = ''
    elif options.dry_run:
        options.mode = ' --test --noop'
    else:
        options.mode = ' --test'

    if options.tags:
        options.tags = ' --tags %s' % options.tags

    return options


def updateMaster(options):
    print 'Updating data on the puppet master...'
    remoteCommand = ' && '.join([
        'sudo hg pull -u -R /etc/puppet/infrastructure',
        'sudo hg pull -u -R /etc/puppet/infrastructure/modules/private',
        'sudo /etc/puppet/infrastructure/ensure_dependencies.py /etc/puppet/infrastructure',
    ])
    runCommand(options.user, options.remote, remoteCommand)


def updateClient(user, host, mode, tags):
    print 'Provisioning %s...' % host
    remoteCommand = 'sudo puppet agent%s%s' % (mode, tags or '')
    print 'Remote command is %s' % remoteCommand

    # Have to ignore errors here, Puppet will return non-zero for successful runs
    runCommand(user, host, remoteCommand, ignore_errors=True)

if __name__ == '__main__':
    options = parseOptions(sys.argv[1:])
    updateMaster(options)
    needKicking = resolveHostList(options)
    if len(needKicking) == 0:
        print >>sys.stderr, 'No valid hosts or groups specified, nothing to do'
        sys.exit(0)
    for host in needKicking:
        updateClient(options.user, host, options.mode, options.tags)
