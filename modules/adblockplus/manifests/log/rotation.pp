# == Type: adblockplus::log::rotation
#
# Setup rotation for a particular log file.
#
# === Parameters:
#
# [*count*]
#   How many intervals to keep rotated logs (see $interval).
#
# [*ensure*]
#   Either 'present' or 'absent'/'purged'.
#
# [*interval*]
#   Either 'daily', 'weekly', 'monthly', or 'yearly'.
#
# [*path*]
#   The full path to the file to rotate, defaults to "/var/log/$name".
#
# [*postrotate*]
#   A single command string or multiple commands in array form, to
#   become exectued after every successful rotation.
#
# [*upload*]
#   Whether to export the rotated *.1.gz to the $adblockplus::log::uplink.
#
# === Examples:
#
#   adblockplus::log::rotation {'nginx_error_log':
#     count => 30,
#     ensure => 'present',
#     interval => 'daily',
#     path => '/var/log/nginx/error.log',
#     postrotate => [
#       '[ ! -f /var/run/nginx.pid ] || kill -USR1 `cat /var/run/nginx.pid`',
#     ],
#     upload => true,
#   }
#
define adblockplus::log::rotation (
  $count = 30,
  $ensure = 'present',
  $interval = 'daily',
  $path = "/var/log/$name",
  $postrotate = [],
  $upload = false,
) {

  include adblockplus::log
  include logrotate

  logrotate::config {$title:
    content => template('adblockplus/log/rotation.erb'),
    ensure => $ensure,
    name => $name,
  }
}
