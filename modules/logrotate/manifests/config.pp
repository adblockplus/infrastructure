# == Type: logrotate::config
#
# A shorthand wrapper that sets up a logrotate configuration file resources
# with the same $title, and properly configured attributes like e.g. $path.
#
# === Parameters:
#
# [*content*]
#   Translates directly into the configuration file content.
#   Mutually exclusive with $source.
#
# [*ensure*]
#   Any value beside 'absent' and 'purged' will ensure the configuration
#   file being 'present'.
#
# [*name*]
#   The actual configuration file base name (defaults to $title).
#
# [*source*]
#   Translates directly into the configuration file source.
#   Mutually exclusive with $content.
#
# === Examples:
#
#   logrotate::config {'gamma':
#     ensure => 'present',
#     source => 'puppet:///logrotate.conf',
#   }
#
#   logrotate::config {'delta':
#     content => template('custom/logrotate.erb'),
#     ensure => 'present',
#   }
#
#   logrotate::config {'void-alpha':
#     ensure => 'absent',
#     name => 'alpha',
#   }
#
define logrotate::config (
  $content = undef,
  $ensure = 'present',
  $source = undef,
) {

  file {$title:
    content => $content,
    ensure => $ensure ? {
      /^(absent|purged)$/ => 'absent',
      default => 'present',
    },
    group => 'root',
    mode => 0644,
    owner => 'root',
    path => "/etc/logrotate.d/$name",
    source => $source,
  }
}
