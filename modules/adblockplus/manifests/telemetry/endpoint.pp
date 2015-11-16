# == Type: adblockplus::telemetry::endpoint
#
# Manage POST endoints of the $adblockplus::telemetry::domain.
#
# === Parameters:
#
# [*ensure*]
#   Whether the endpoint should be 'present' or 'absent'/'purged'.
#
# [*location*]
#   The path to the endpoint within the $adblockplus::telemtry::domain,
#   i.e. https://telemetry.adblockplus.org/$location (defaults to /$name).
#
# [*name*]
#   Identifies the data file (i.e. /var/log/nginx/telemetry_log_$name).
#
# === Examples:
#
#   adblockplus::telemetry::endpoint {'filter-hit-statistics':
#     ensure = 'present',
#     location = '/submit/filter-hit-statistics',
#   }
#
define adblockplus::telemetry::endpoint (
  $ensure = 'present',
  $location = "/$name",
) {

  include adblockplus::telemetry
  include nginx

  $ensure_presence = $ensure ? {
    /^(absent|purged)$/ => 'absent',
    default => 'present',
  }

  $id = "adblockplus::telemetry::endpoint#$name"
  $logfile = "/var/log/nginx/telemetry_log_$name"

  concat::fragment {$id:
    content => template('adblockplus/telemetry/endpoint.conf.erb'),
    ensure => $ensure_presence,
    notify => Service['nginx'],
    order => 4,
    target => $adblockplus::telemetry::endpoints_config_name,
  }

  logrotate::config {$id:
    content => template('adblockplus/telemetry/logrotate.erb'),
    ensure => $ensure_presence,
    name => "telemetry_$name",
  }
}
