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
define adblockplus::web::fileserver::repository (
  $ensure = 'present',
  $users = {},
){

  $repositories_directory = "$adblockplus::directory/fileserver"
  $repository_directory = "$repositories_directory/$name"
  $group_name = "www-$name"
  $repository_host = $name ? {
    'www' =>  "$adblockplus::web::fileserver::domain",
    default => "$name.$adblockplus::web::fileserver::domain",
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

