# == Class: adblockplus::log
#
# Default root namespace for integrating custom logging entities.
#
# === Parameters:
#
# [*rotations*]
#   A hash of adblockplus::log::rotation $name => $parameter items
#   to set up in this context, i.e. via Hiera.
#
# === Examples:
#
#   class {'adblockplus::log':
#     rotations => {
#       # see adblockplus::log::rotation
#     },
#   }
#
class adblockplus::log (
  $rotations = hiera('adblockplus::log::rotations', {}),
) {

  include adblockplus
  realize(File[$adblockplus::directory])

  # Used as internal constants within adblockplus::log::* resources
  $directory = "$adblockplus::directory/log"
  $group = 'log'
  $user = 'log'

  # Invoke realize(File[$adblockplus::log::directory]) when neccessary
  @file {$directory:
    ensure => 'directory',
    require => File[$adblockplus::directory],
  }

  # Invoke realize(User[$adblockplus::log::user]) when necessary
  @user {$user:
    ensure => 'present',
    managehome => true,
  }

  # See modules/adblockplus/manifests/log/rotation.pp
  create_resources('adblockplus::log::rotation', $rotations)
}
