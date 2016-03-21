# == Type: fluent::config
#
# Maintain Fluentd configuration files.
#
# Use "@include config.d/*.conf" in the main configuration ($fluent::config)
# to include all fragments at once, or "@include config.d/$name.conf" to pick
# and choose.
#
# Type fluent::config is a thin layer around a single Puppet file resource
# definition, combining the available parameters with ones computed internally
# (aligned with http://docs.fluentd.org/articles/config-file).
#
# === Parameters:
#
# [*content*]
#   Translates directly into the file $content parameter.
#
# [*ensure*]
#   Translates directly into the file $ensure parameter.
#
# [*name*]
#   Used as basename (without .conf extension or directory path) when
#   generating the config file $path.
#
# [*source*]
#   Translates directly into the file $source parameter.
#
# [*target*]
#   Translates directly into the file $target parameter.
#
# === Examples:
#
#   fluent::config {'example1':
#     name => 'my_config',
#     source => 'puppet:///modules/custom/fluentd.conf',
#   }
#
#   fluent::config {'example2':
#     ensure => 'link',
#     target => '/opt/custom-stuff/fluentd.conf',
#   }
#
define fluent::config (
  $content = undef,
  $ensure = 'present',
  $source = undef,
  $target = undef,
) {

  include fluent
  include stdlib

  file {"fluent::config#$title":
    content => $content,
    ensure => $ensure,
    group => $fluent::group,
    mode => 0640,
    notify => Service['fluent'],
    owner => getparam(File['fluent'], 'owner'),
    path =>  "$fluent::directory/config.d/$name.conf",
    require => File["$fluent::directory/config.d"],
    source => $source,
    target => $target,
  }
}
