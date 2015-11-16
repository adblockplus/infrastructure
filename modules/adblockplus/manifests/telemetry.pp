# == Class: adblockplus::telemetry
#
# A receiver for incoming statistic data and reports.
#
# === Parameters:
#
# [*domain*]
#   The authorative domain to bind to, although the setup will ensure
#   the host being the one used by default.
#
# [*endpoints*]
#   A hash of adblockplus::telemetry::endpoint setup parameters to become
#   included with the class.
#
# [*ssl_cert*]
#   If provided, the host will bind to HTTPS, and redirect from HTTP.
#   Requires $ssl_key to be given as well.
#
# [*ssl_key*]
#   The private SSL key the $ssl_cert is associated with.
#
# === Examples:
#
#   class {'adblockplus::telemetry':
#     domain => 'telemetry.adblockplus.org',
#     endpoints => {
#       # see adblockplus::telemetry::endpoint
#     },
#   }
#
class adblockplus::telemetry (
  $domain,
  $endpoints = hiera('adblockplus::telemetry::endpoints', {}),
  $ssl_cert = hiera('adblockplus::telemetry::ssl_cert', ''),
  $ssl_key = hiera('adblockplus::telemetry::ssl_key', ''),
) {

  include adblockplus
  include nginx

  $endpoints_config_name = 'adblockplus::telemetry#endpoints'
  $endpoints_config_path = '/etc/nginx/adblockplus_telemetry_endpoints.conf'

  concat {$endpoints_config_name:
    notify => Service['nginx'],
    path => $endpoints_config_path,
    require => Package['nginx'],
  }

  create_resources('adblockplus::telemetry::endpoint', $endpoints, {
    ensure => 'present',
  })

  nginx::hostconfig {$domain:
    certificate => $ssl_cert ? {'' => undef, default => $ssl_cert},
    content => "include $endpoints_config_path;\n",
    is_default => true,
    private_key => $ssl_key ? {'' => undef, default => $ssl_key},
    log => 'access_log_telemetry',
    require => Concat[$endpoints_config_name],
  }
}
