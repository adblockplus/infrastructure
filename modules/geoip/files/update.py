#!/usr/bin/env python

import urllib
import zlib

downloads = {
    '/usr/share/GeoIP/GeoIP.dat': 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz',
    '/usr/share/GeoIP/GeoIPv6.dat': 'http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz',

    '/usr/share/GeoIP/GeoIPCity.dat': 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz',
    '/usr/share/GeoIP/GeoIPCityv6.dat': 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz',
}

for dest, source in downloads.iteritems():
    data = urllib.urlopen(source).read()
    with open(dest, "wb") as f:
        # wbit parameter value isn't properly documented, see https://stackoverflow.com/a/22310760/785541
        f.write(zlib.decompress(data, zlib.MAX_WBITS | 16))
