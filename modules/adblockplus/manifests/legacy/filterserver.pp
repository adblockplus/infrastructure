# == Class: adblockplus::legacy::filterserver
#
# See http://hub.eyeo.com/issues/2762 for more information.
#
class adblockplus::legacy::filterserver {

  include filterserver

  package {'geoip-database-contrib':
    ensure => 'purged',
  }
}

