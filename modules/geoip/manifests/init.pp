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
  $packages = ['geoip-database'],
  $script = '/usr/local/sbin/update-geoip-database',
) {

  ensure_resource('package', $packages, {
    ensure => $ensure,
  })

  create_resources('cron', {geoip => $cron}, {
    command => $hook ? {undef => $script, default => "$script && $hook"},
    ensure => $ensure ? {/^(absent|purged)$/ => 'absent', default => 'present'},
    hour => 0,
    minute => 0,
    user => 'root',
  })

  file {$script:
    before => Cron['geoip'],
    ensure => $ensure ? {/^(absent|purged)$/ => 'absent', default => 'present'},
    mode => 0755,
    require => Package[$packages],
    source => 'puppet:///modules/geoip/update.py',
  }
}
