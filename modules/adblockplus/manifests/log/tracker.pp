# == Type: adblockplus::log::tracker
#
# Establish monitoring for a single log-file source on the current node,
# connected to the adblockplus::log::forwarder output, if any.
#
# === Parameters:
#
# [*ensure*]
#   Whether the tracker is supposed to be 'present' or 'absent', defaults
#   to $adblockplus::log::ensure.
#
# [*format*]
#   Either the name of a pre-configured format specific to the (Fluentd)
#   system setup or a regular expression with named groups for extracting
#   the log event's properties.
#
# [*name*]
#   Translates literally into a tag attached to the tracked log event.
#
# [*path*]
#   The full path to the log file being tracked, required to be unique.
#
# === Examples:
#
#   adblockplus::log::tracker {'example1':
#     format => 'nginx',
#     name => 'foobar.access',
#     path => '/var/log/nginx/access.log',
#   }
#
#   adblockplus::log::tracker {'example2':
#     path => '/var/log/nginx/error.log',
#     name => 'foobar.error',
#     format => '/^(?<message>.+)$/',
#   }
#
#   adblockplus::log::tracker {'/var/log/other.log':
#     ensure => 'absent',
#   }
#
define adblockplus::log::tracker (
  $ensure = undef,
  $format = '/^(?<message>.*)$/',
  $path = $title,
) {

  include adblockplus::log::forwarder
  include stdlib

  # Used as $title for all resource definitions contained herein
  $namevar = "adblockplus::log::tracker#$title"

  # See modules/fluent/manifests/config.pp
  fluent::config {$namevar:
    content => template('adblockplus/log/fluentd/tracker.conf.erb'),
    ensure => pick($ensure, $adblockplus::log::ensure),
    name => sprintf('20-adblockplus-log-tracker-%s', md5($path)),
  }
}
