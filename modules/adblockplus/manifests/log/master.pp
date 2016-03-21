# == Class: adblockplus::log::master
#
# A server setup to collect and pre-process log files. This is still a stub,
# the generated configuration corresponds to recent package defaults.
#
# === Parameters:
#
# [*ensure*]
#   Whether the master setup should be 'present' or 'absent', defaults
#   to $adblockplus::log::ensure.
#
# === Examples:
#
#   class {'adblockplus::log::master':
#   }
#
class adblockplus::log::master (
  $ensure = undef,
) {

  include adblockplus::log
  include adblockplus::log::processor
  include stdlib

  # Virtual resource from modules/adblockplus/manifests/init.pp
  realize(File[$adblockplus::directory])

  # Virtual resource from modules/adblockplus/manifests/log.pp
  realize(File[$adblockplus::log::directory])
  realize(User[$adblockplus::log::user])

  # See modules/fluent/manifests/config.pp
  fluent::config {$title:
    content => template('adblockplus/log/fluentd/master.conf.erb'),
    ensure => pick($ensure, $adblockplus::log::ensure),
    name => '50-adblockplus-log-master',
  }
}
