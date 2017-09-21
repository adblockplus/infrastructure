# == Class: adblockplus::web::fileserver
#
# A fileserver serves multiple file repositories.
#
# === Parameters:
#
# [*domain*]
#   A string which is the name of the fileserver domain, under which
#   each repository has a subdomain.
#
# [*certificate*]
#   The name of the SSL certificate file within modules/private/files, if any.
#   Requires a private_key as well.
#
# [*private_key*]
#   The name of the private key file within modules/private/files, if any.
#   Requires a certificate as well.
#
# [*is_default*]
#  Passed on to nginx (whether or not the site config should be default).
#
# [*repositories*]
#   A collection (hash) of repositories to serve.
#   The contents of a repository is served on a subdomain of the fileserver.
#
class adblockplus::web::fileserver(
  $ensure = 'present',
  $domain,
  $certificate = undef,
  $private_key = undef,
  $repositories={},
){

  include nginx
  include adblockplus
  include adblockplus::web

  realize(File[$adblockplus::directory])

  file {"$adblockplus::directory/fileserver":
    ensure => directory,
  }

  ensure_resources('adblockplus::web::fileserver::repository', $repositories, {
    ensure => 'present',
  })

  nginx::hostconfig{ "$domain":
    source => 'puppet:///modules/adblockplus/nginx/fileserver.conf',
    is_default => true,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_fileserver',
  }
}

