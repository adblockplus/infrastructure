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
# Members are handled manually on the target server for now.
#      Figure out how to provision them some day.
#
define adblockplus::web::fileserver::repository (
  $ensure = 'present',
){

  $repositories_directory = "$adblockplus::directory/fileserver"
  $repository_directory = "$repositories_directory/$name"
  $repository_host = "$name.$adblockplus::web::fileserver::domain"

  group {"www-$name":
    ensure => $ensure,
  }

  file {"$repository_directory":
    ensure => ensure_directory_state($ensure),
    group => "www-$name",
    mode => '0775',
    require => [
      File["$repositories_directory"],
      Group["www-$name"],
    ],
  }

  realize(File[$adblockplus::directory])

  file {"/var/www/$repository_host":
    ensure => ensure_symlink_state($ensure),
    target => "$repository_directory",
    require => File["$repository_directory"],
  }
}

