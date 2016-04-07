# == Class: adblockplus::log::forwarder
#
# Additional configuration for forwarding log file information processed with
# Fluentd and utilized by i.e. adblockplus::log::tracker instances.
#
# === Parameters:
#
# [*ensure*]
#   Whether the forwarder setup should be 'present' or 'absent', defaults
#   to $adblockplus::log::ensure.
#
# [*host*]
#   The hostname of the adblockplus::log::master in this environment.
#
# [*port*]
#   The port number for log event packages (TCP) and heartbeat messages (UDP).
#
# === Example:
#
#   class {'adblockplus::log::forwarder':
#     host => 'logmaster.localdomain',
#     port => 24224,
#   }
#
class adblockplus::log::forwarder (
  $ensure = $adblockplus::log::ensure,
  $host = "log1.$adblockplus::authority",
  $port = 24224,
) {

  include adblockplus::log
  include stdlib

  # See modules/fluent/manifests/config.pp
  fluent::config {$title:
    content => template('adblockplus/log/fluentd/forwarder.conf.erb'),
    ensure => pick($ensure, $adblockplus::log::ensure),
    name => '80-adblockplus-log-forwarder',
  }
}
