#!/usr/bin/env python

import contextlib
import os
import tarfile
import urllib
import zlib

downloads = {
    '/usr/share/GeoIP/GeoIPv6.dat': 'http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz',
    '/usr/share/GeoIP/GeoIPCityv6.dat': 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz',

    '/usr/share/GeoIP/GeoIP2.tar': 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz',
    '/usr/share/GeoIP/GeoIP2City.tar': 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz',
}

for dest, source in downloads.iteritems():
    data = urllib.urlopen(source).read()
    with open(dest, "wb") as f:
        # wbit parameter value isn't properly documented, see https://stackoverflow.com/a/22310760/785541
        f.write(zlib.decompress(data, zlib.MAX_WBITS | 16))

for path in filter(lambda key: key.endswith('.tar'), downloads.keys()):
    dirname = os.path.dirname(path)
    with contextlib.closing(tarfile.open(path)) as archive:
        archive.extractall(path=dirname)
        is_database = lambda info: info.name.endswith('.mmdb')
        for database in filter(is_database, archive.getmembers()):
            target = os.path.join(dirname, os.path.basename(database.name))
            intermediate = target + '.new'
            os.symlink(database.name, intermediate)
            os.rename(intermediate, target)
