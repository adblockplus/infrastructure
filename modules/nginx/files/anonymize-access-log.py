#!/usr/bin/env python
"""Anonymize data in access log lines.

Read a line from stdin, write it to stdout with the following changes:
1. IP (v4 or v6) replaced with a salted hash of the IP and the date
2. Country information (extracted from IP) added after the salted hash.

If the country information is unavailable in the database, '-' is added instead
of ISO 3166-1 alpha-2 country code (like 'DE').

Salt and the country information database are taken as command line options and
default to environment variables.

Malformed lines are passed on as is, based on the assumption that they don't
contain sensitive information. Malformed here means the line couldn't be split
on space character. If it could be split, and an error occurs afterwards
(e.g. while trying to parse out the date), the script will fail and exit in
order to bring attention to the fact that something might not be getting
anonymized.
"""

from __future__ import print_function
from __future__ import unicode_literals

import argparse
import hashlib
import hmac
import os
import sys

import geoip2.database


def main(salt, country_db):
    reader = geoip2.database.Reader(country_db)
    salt = salt.encode('utf-8')

    for line in sys.stdin:
        try:
            ip, non_sensitive_info = line.split(' ', 1)
        except ValueError:
            print(line, end='')
            continue

        # http://geoip2.readthedocs.io/en/latest/#geoip2.database.Reader.country
        try:
            record = reader.country(ip)
        except geoip2.errors.AddressNotFoundError:
            country = '-'
        else:
            country = record.country.iso_code

        # 218.215.212.209 - - [04/May/2018:05:20:48 +0000] "GET /...
        date_start = line.index('[') + 1
        # IP might be v4 or v6
        date_end = line.index(':', date_start)
        date = line[date_start:date_end]

        # https://docs.python.org/2/library/hmac.html
        to_hash = (ip + date).encode('utf-8')
        token = hmac.HMAC(salt, to_hash, hashlib.sha1).hexdigest()

        print(token, country, non_sensitive_info, end='')

    reader.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Filter out sensitive data from access logs',
    )

    parser.add_argument(
        '--salt',
        dest='salt',
        default=os.getenv('ANONYMIZE_SALT'),
        help='Salt for hashing sensitive data, defaults to $ANONYMIZE_SALT'
    )

    # https://dev.maxmind.com/geoip/geoip2/geolite2/
    parser.add_argument(
        '--geolite2-db',
        dest='country_db',
        default=os.getenv('ANONYMIZE_GEOLITE2_DB'),
        help='Path to MaxMind DB file with GeoLite2 Country data, defaults '
             'to $ANONYMIZE_GEOLITE2_DB'
    )

    args = parser.parse_args()

    if args.salt is None or args.country_db is None:
        parser.print_help()
        sys.exit(1)

    main(args.salt, args.country_db)
