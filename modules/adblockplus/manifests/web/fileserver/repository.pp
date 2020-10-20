# == Type: adblockplus::web::fileserver::repository
#
# Manage a repository on a fileserver.
#
# A repository is a site where a group of people can upload and artifacts.
#
# In its current form, a repository is simply a directory exposed on a web
# server. This may evolve to make use of more advanced repositories in the
# future (proxy to repository manager, or 3rd-party service, etc).
#
# === parameters:
#
# [*ensure*]
#   Whether to set up the repository or not. Removing repositories is not
#   supported.
#
# [*users*]
# System users that should be created and added to the group that has 
# write permissions for the repository directory
#
# [*auth_file*]
#   Overwrite the default options of the authentication file used for basic
#   http authentication for nginx.
#
# [*aliases*]
#  Array of alternative names that will be redirected to the main virtual host
define adblockplus::web::fileserver::repository (
  $ensure = 'present',
  $users = {},
  $auth_file = undef,
  $aliases = [],
  $autoindex = undef,
){

  $repositories_directory = "$adblockplus::directory/fileserver"
  $repository_directory = "$repositories_directory/$name"
  $group_name = "www-$name"
  $repository_host = $name ? {
    'www' =>  "$adblockplus::web::fileserver::domain",
    default => "$name.$adblockplus::web::fileserver::domain",
  }
  $auth_filename = "${::adblockplus::directory}/htpasswd/${name}"

  nginx::hostconfig {"$repository_host":
    global_config => template("web/global.conf.erb"),
    content => template("adblockplus/web/fileserver.conf.erb"),
    is_default => false,
    certificate => $adblockplus::web::fileserver::certificate,
    private_key => $adblockplus::web::fileserver::private_key,
    log => "access_log_$repository_host",
  }

  if $auth_file != undef {
    ensure_resource('file', $auth_filename, merge({
      ensure => ensure_file_state($ensure),
    }, $auth_file))
  }

  group {"$group_name":
    ensure => $ensure,
  }

  file {"$repository_directory":
    ensure => ensure_directory_state($ensure),
    group => $group_name,
    mode => '0775',
    require => [
      File["$repositories_directory"],
      Group[$group_name],
    ],
  }

  ensure_resources('adblockplus::user', $users, {
    ensure => $ensure,
    password_hash => '*',
    groups => [$group_name],
  })

  realize(File[$adblockplus::directory])

  file {"/var/www/$repository_host":
    ensure => ensure_symlink_state($ensure),
    target => "$repository_directory",
    require => File["$repository_directory"],
  }
}

