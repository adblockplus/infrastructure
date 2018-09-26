# == Class: adblockplus::web::redirector
#
# Manage a simple Nginx-based service for HTTP redirects.
#
# See http://hub.eyeo.com/issues/1653 for a use case example,
# and http://hub.eyeo.com/issues/1975 for more information.
#
# === Parameters:
#
# [*aliases*]
#   A list of zero or more domain aliases.
#
# [*default*]
#   The default URL to redirect to.
#
# [*domain*]
#   The domain name the redirector instance is associated with.
#
# [*ssl_certificate*]
#   The name of the SSL certificate file within modules/private/files, if any.
#   Requires a private_key as well.
#
# [*ssl_private_key*]
#   The name of the private key file within modules/private/files, if any.
#   Requires a certificate as well.
#
# [*targets*]
#   A hash of zero or more redirect URL items indexed by the associated URL
#   slug, respectively.
#
# [*custom_config*]
#   A string that allows custom nginx configuration being written to the
#   configuration file.
#
# === Examples:
#
#   class {'adblockplus::web::redirector':
#     domain => 'adblockplus.to',
#     targets => {
#       'jobs' => 'https://eyeo.com/en/jobs',
#       'team' => 'https://eyeo.com/en/team',
#     },
#   }
#
class adblockplus::web::redirector (
  $aliases = [],
  $default = 'https://adblockplus.org/',
  $domain = $::domain,
  $ssl_certificate = undef,
  $ssl_private_key = undef,
  $targets = {},
  $custom_config = undef,
) {

  include nginx

  nginx::hostconfig {$title:
    alt_names => $aliases,
    content => template('adblockplus/web/redirector.conf.erb'),
    certificate => $ssl_certificate,
    domain => $domain,
    is_default => true,
    private_key => $ssl_private_key,
    log => 'access_log_redirects',
  }
}
