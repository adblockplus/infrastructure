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