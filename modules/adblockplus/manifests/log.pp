# == Class: adblockplus::log
#
# Default root namespace for integrating custom logging entities.
#
# === Parameters:
#
# [*ensure*]
#   Whether associated resources are ment to be 'present' or 'absent'.
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
  $ensure = 'present',
  $rotations = hiera('adblockplus::log::rotations', {}),
) {

  include adblockplus

  # Used as internal constants within adblockplus::log::* resources
  $directory = "$adblockplus::directory/log"
  $group = 'adm'
  $user = 'log'

  # Required on both log generating and log processing hosts
  class {'fluent':
    package => {
      ensure =>  $ensure ? {
        'present' => '2.3.1-0',
        default => 'absent',
      },
      provider => 'apt',
    },
    user => {
      groups => [$group],
      shell => '/bin/sh',
    }
  }

  # Invoke realize(File[$adblockplus::log::directory]) when neccessary
  @file {$directory:
    ensure => 'directory',
    group => $group,
    mode => 0750,
    owner => 'root',
    require => File[$adblockplus::directory],
  }

  # Invoke realize(User[$adblockplus::log::user]) when necessary
  @user {$user:
    ensure => $ensure,
    managehome => true,
    groups => [$group],
  }

  # See modules/adblockplus/manifests/log/rotation.pp
  create_resources('adblockplus::log::rotation', $rotations)
}
