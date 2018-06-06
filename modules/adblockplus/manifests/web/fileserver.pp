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

  file {"${::adblockplus::directory}/htpasswd":
    ensure => directory,
  }

  ensure_resources('adblockplus::web::fileserver::repository', $repositories, {
    ensure => 'present',
  })
}

