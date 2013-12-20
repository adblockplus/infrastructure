#!/bin/sh

#
# paranoia settings
#
umask 022

PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH

wget -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz -O /tmp/GeoIP.dat.gz
test -e /tmp/GeoIP.dat.gz && gzip -fd /tmp/GeoIP.dat.gz
test -e /tmp/GeoIP.dat && mv -f /tmp/GeoIP.dat /usr/share/GeoIP/GeoIP.dat

wget -q http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz -O /tmp/GeoIPv6.dat.gz
test -e /tmp/GeoIPv6.dat.gz && gzip -fd /tmp/GeoIPv6.dat.gz
test -e /tmp/GeoIPv6.dat && mv -f /tmp/GeoIPv6.dat /usr/share/GeoIP/GeoIPv6.dat
