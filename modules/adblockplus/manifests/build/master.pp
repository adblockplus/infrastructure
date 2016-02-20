# == Class: adblockplus::build::master
#
# An authoritative build-server setup based on Buildbot and Nginx.
#
# === Parameters:
#
# [*domain*]
#   The domain name associated with the Buildbot waterfall page.
#
# [*is_default_domain*]
#   Whether the Buildbot page should serve as the default content
#   handler with the HTTP server setup.
#
# [*buildbot_config*]
#   Translates directly into the $buildbot::master::config option.
#
# [*ssl_cert*]
#   The SSL certificate file name within the private module, if any.
#   Requires an $ssl_key to be provided as well.
#
# [*ssl_key*]
#   The SSL key file name within the private module, if any.
#   Requires an $ssl_cert to be provided as well.
#
# [*slaves*]
#   Local buildbot::slave records to setup with the master.
#
# [*slave_credentials*]
#   Name => password pairs of e.g. remote build slaves.
#
# === Examples:
#
#   class {'adblockplus::build::master':
#     domain => 'localhost',
#     is_default_domain => true,
#   }
#
class adblockplus::build::master (
  $domain,
  $is_default_domain = false,
  $buildbot_config = {},
  $ssl_cert = hiera('adblockplus::build::master::ssl_cert', 'undef'),
  $ssl_key = hiera('adblockplus::build::master::ssl_key', 'undef'),
  $slaves = hiera('adblockplus::build::master::slaves', {}),
  $slave_credentials = hiera('adblockplus::build::master::slave_credentials', {}),
) {

  include nginx

  # change default behavior, but still recognize hiera values
  class {'buildbot':
    master_service => hiera('buildbot::master_service', 'running'),
    slave_service => hiera('buildbot::slave_service', 'running'),
  }

  # Computable $buildbot::master::config parameters
  $default_scheme = $ssl_cert ? {/^(undef|)$/ => 'http', default => 'https'}
  $default_config = {
    'buildbotURL' => sprintf('%s://%s/', $default_scheme, $domain),
  }

  buildbot::master {'default':
    config => merge($default_config, $buildbot_config),
    slaves => $slaves,
    slave_credentials => $slave_credentials,
    system => true,
  }

  buildbot::fragment {'custom':
    authority => Buildbot::Master['default'],
    content => template('adblockplus/buildmaster.erb'),
  }

  nginx::hostconfig {$domain:
    certificate => $ssl_cert ? {
      'undef' => undef,
      default => $ssl_cert,
    },
    source => 'puppet:///modules/adblockplus/nginx/buildmaster.conf',
    is_default => $is_default_domain,
    log => 'access_log_buildbot',
    private_key => $ssl_key ? {
      'undef' => undef,
      default => $ssl_key,
    },
  }
}
