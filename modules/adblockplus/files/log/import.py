#!/usr/bin/env python
# -*- coding: utf-8 -*- ------------------------------------------------
# vi:set fenc=utf-8 ft=python ts=8 et sw=4 sts=4:

__doc__ = """ Redirect STDIN into an ABP log channel.

"""
import argparse
import fcntl
import os
import shutil
import sys

try:
    parser = argparse.ArgumentParser(allow_abbrev=False, description=__doc__)
except TypeError:
    parser = argparse.ArgumentParser(description=__doc__)

parser.add_argument(
    'name',
    help='The base name of the logfile to import',
    metavar='LOG',
    type=str,
)

parser.add_argument(
    '-s', '--source',
    help='The name (recommended) or IP of the source host',
    metavar='HOSTNAME',
    type=str,
)

parser.add_argument(
    '-t', '--target',
    help='The location of the upload/import directory',
    metavar='DIRECTORY',
    type=str,
)

arguments = parser.parse_args()
destination = os.path.join(arguments.target, arguments.source, arguments.name)
output = open(destination, 'a')
fcntl.flock(output, fcntl.F_WRLCK | fcntl.F_EXLCK)

try:
    shutil.copyfileobj(sys.stdin, output)
finally:
    fcntl.flock(output, fcntl.F_UNLCK)

output.close()
