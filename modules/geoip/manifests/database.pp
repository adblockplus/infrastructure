# == Class: geoip::database
#
# Manage GeoIP (https://dev.maxmind.com/geoip/geoip2/geolite2/) databases and
# convert the .mmdb format to legace .dat format.
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
# [*source*]
#   URL where the database is gonna be fetched.
#
class geoip::database (
  $cron = {},
  $ensure = 'present',
  $hook = undef,
  $packages = [
    'git',
  ],
  $source = 'https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country-CSV.zip',
) {

  ensure_resource('package', $packages, {
    ensure => $ensure,
  })

  exec {'fetch-geolite2legacy-repo':
    command => "git clone https://gitlab.com/eyeo/devops/dependencies/geolite2legacy.git /opt/geolite2legacy",
    path => ["/usr/bin/", "/bin/"],
    user => root,
    timeout => 0,
    require => Package['git'],
    creates => "/opt/geolite2legacy/.git",
  }

  ensure_resource('package', ['pygeoip', 'ipaddr'], {
    ensure => $ensure,
    provider => 'pip',
    require => Package['python-pip'],
  })

  realize(File[$adblockplus::directory])

  $geoip_directory = "${adblockplus::directory}/fileserver/geoip"

  $script = join([
    "/usr/bin/wget -q ${source} -O $(date +${geoip_directory}/GeoIPv6_\\%Y_\\%m_\\%d).zip",
    "cd ${geoip_directory}",
    '/opt/geolite2legacy/geolite2legacy.py -i $(date +GeoIPv6_\%Y_\%m_\%d).zip -f /opt/geolite2legacy/geoname2fips.csv -o $(date +GeoIPv6_\%Y_\%m_\%d).dat -6 1>/dev/null',
  ], '&&')

  create_resources('cron', {geoip => $cron}, {
    command => $hook ? {undef => $script, default => "$script && $hook"},
    ensure => $ensure,
    hour => 0,
    minute => 0,
    user => 'root',
  })

}
