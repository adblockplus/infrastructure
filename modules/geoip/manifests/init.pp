# == Class: geoip
#
# Manage GeoIP (http://dev.maxmind.com/geoip/) databases.
#
# === Parameters:
#
# [*cron*]
#   Default options for Cron['geoip'], e.g. $minute, $monthday etc.
#
# [*ensure*]
#   Either 'present', 'absent' or 'purged'.
#
# [*hook*]
#   A command to execute when Cron['geoip'] has succeeded, optional.
#
# [*packages*]
#   The names of the GeoIP packages.
#
# [*script*]
#   Where to store the update script executed by Cron['geoip'].
#
# === Examples:
#
#   class {'geoip':
#     cron => {
#       'environment' => ['PYTHONPATH=/opt/custom'],
#       'minute' => 0,
#       'hour' => 8,
#       'monthday' => 15,
#     },
#   }
#
class geoip (
  $cron = {},
  $ensure = 'present',
  $hook = undef,
  $packages = [
    'geoip-database',
    'python-geoip',
  ],
) {

  ensure_resource('package', $packages, {
    ensure => $ensure,
  })

  ensure_resource('package', 'python-geoip2', {
    ensure => $ensure,
    name => 'geoip2',
    provider => 'pip',
    require => Package['python-pip'],
  })

  $script = 'wget https://geoip.eyeofiles.com/GeoIPv6.dat -O /usr/share/GeoIP/GeoIPv6.dat'

  create_resources('cron', {geoip => $cron}, {
    command => $hook ? {undef => $script, default => "$script && $hook"},
    ensure => $ensure ? {/^(absent|purged)$/ => 'absent', default => 'present'},
    hour => 1,
    minute => 0,
    user => 'root',
  })

}
