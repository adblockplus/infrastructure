# == Class: adblockplus::log
#
# Default root namespace for integrating custom logging entities.
#
# === Parameters:
#
# [*ensure*]
#   Whether associated resources are ment to be 'present' or 'absent'.
#
# [*name*]
#   Used as label to connect adblockplus::log::tracker instances to class
#   adblockplus::log::forwarder, defaults to 'adblockplus::log'.
#
# [*rotations*]
#   A hash of adblockplus::log::rotation $name => $parameter items
#   to set up in this context, i.e. via Hiera.
#
# [*trackers*]
#   A hash of adblockplus::log::rotation $title => $parameter items
#   to set up in this context, i.e. via Hiera.
#
# === Examples:
#
#   class {'adblockplus::log':
#     rotations => {
#       # see adblockplus::log::rotation
#     },
#     trackers => {
#       # see adblockplus::log::tracker
#     },
#   }
#
class adblockplus::log (
  $ensure = 'present',
  $rotations = hiera('adblockplus::log::rotations', {}),
  $trackers = hiera('adblockplus::log::trackers', {}),
) {

  include adblockplus
  include stdlib

  # Used as internal constants within adblockplus::log::* resources
  $directory = "$adblockplus::directory/log/data"
  $user = 'log'

  # Required on both log generating and log processing hosts
  class {'fluent':
    package => {
      ensure =>  $ensure ? {
        'present' => '2.3.*',
        default => 'absent',
      },
      provider => 'apt',
    },
    user => {
      groups => ['adm'],
      shell => '/bin/sh',
    },
  }

  # Used as internal shortcuts within adblockplus::log::* resources
  $agent = getparam(Package['fluent'], 'name')
  $index = sprintf('/var/run/%s/index.csv', $agent)
  $group = getparam(User['fluent'], 'gid')

  fluent::config {$title:
    content => template('adblockplus/log/fluentd/default.conf.erb'),
    ensure => $ensure,
    name => '90-adblockplus-log-defaults',
  }

  # Invoke realize(File[$adblockplus::log::directory]) when neccessary
  @file {$directory:
    before => Service['fluent'],
    ensure => 'directory',
    group => $group,
    mode => '0775',
    owner => $user,
  }

  # Invoke realize(User[$adblockplus::log::user]) when necessary
  @user {$user:
    before => File[$directory],
    ensure => $ensure,
    groups => [$group],
    home => "$adblockplus::directory/log",
    managehome => true,
    require => [
      File[$adblockplus::directory],
      User['fluent'],
    ],
  }

  # See modules/adblockplus/manifests/log/rotation.pp
  create_resources('adblockplus::log::rotation', $rotations)

  # See modules/adblockplus/manifests/log/tracker.pp
  create_resources('adblockplus::log::tracker', $trackers)
}
