# == Class: discourse_docker
#
# Depends on module docker (for now)
#
# == Parameters:

# [*domain*]
#  Set the domain (hostname) for the site. This will be used in both nginx and discourse settings.
#
# [*certificate*]
#  SSL cert file (in modules/private/files/) for using in nginx.
#
# [*private_key*]
#  SSL private key file (in modules/private/files/) for nginx.
#
# [*site_settings*]
#  Hash used for discourse configuration. See https://github.com/discourse/discourse/blob/master/config/site_settings.yml
#  for all defaults and possible options.
#
# [*is_default*]
#  Passed on to nginx (whether or not the site config should be default).
#
# [*admins*]
#  Emails of accounts that will be made admin and developer on initial signup.
#
# [*google_oauth2_client_id*]
#  Client ID from Google API console - see https://developers.google.com/identity/protocols/OAuth2 .
#
# [*google_oauth2_client_secret*]
#  Secret from Google API console - matching client_id above.
#
# === Examples:
#
#   class {'discourse_docker':
#     domain => 'forum.adblockplus.org',
#     certificate => 'forum.adblockplus.org_sslcert.pem',
#     private_key => 'forum.adblockplus.org_sslcert.key',
#     is_default => true,
#     admins => ['test1@adblockplus.org','test2@adblockplus.org'],
#     google_oauth2_client_id => '698703124405-3jodbnl423ie9r01gv4j3ve1olg02sv3.apps.googleusercontent.com',
#     google_oauth2_client_secret => 'tB2ESr1b99qJpbOYqv3PtuPU',
#     site_settings => {
#       title => 'Awesome Forum',
#       # .. many more site settings here...
#     }
#   }
#
class discourse_docker(
  $domain,
  $certificate = hiera('discourse_docker::certificate', undef),
  $private_key = hiera('discourse_docker::private_key', undef),
  $site_settings = hiera('discourse_docker::site_settings', {}),
  $is_default = hiera('discourse_docker::is_default', false),
  $admins = hiera('discourse_docker::admins', []),
  $google_oauth2_client_id = hiera('discourse_docker::google_oauth2_client_id', 'undef'),
  $google_oauth2_client_secret = hiera('discourse_docker::google_oauth2_client_secret', 'undef'),
) {

  include stdlib

  package {'git':
    ensure => present,
  }

  file {'/var/discourse':
    ensure => directory,
    mode => '755',
    owner => root,
    group => root
  }

  exec {'fetch-discourse-docker':
    command => "git clone https://github.com/discourse/discourse_docker.git /var/discourse",
    path => ["/usr/bin/", "/bin/"],
    user => root,
    timeout => 0,
    require => [Package['git'], File['/var/discourse']],
    unless => "test -d /var/discourse/.git"
  }

  file {'/var/discourse/containers/app.yml':
    ensure => file,
    mode => '600',
    owner => root,
    group => root,
    content => template('discourse_docker/app.yml.erb'),
    require => Class['docker'],
  }

  exec {'rebuild':
    command => '/var/discourse/launcher rebuild app --skip-prereqs',
    user => root,
    subscribe => File['/var/discourse/containers/app.yml'],
    refreshonly => true,
    logoutput => 'on_failure',
    timeout => 0,
    require => [Exec['fetch-discourse-docker'],
                Class['docker'],
                Package['git']],
  }

  exec {'start':
    command => '/var/discourse/launcher start app --skip-prereqs',
    user => root,
    logoutput => 'on_failure',
    require => Exec['rebuild'],
  }

  nginx::hostconfig {$domain:
    source => "puppet:///modules/discourse_docker/site.conf",
    certificate => $certificate,
    private_key => $private_key,
    is_default => $is_default,
    log => "access_log_intraforum"
  }
}

