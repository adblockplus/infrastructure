# == Type: fluent::plugin
#
# Maintain Fluentd plugin files.
#
# Type fluent::plugin is a thin layer around a single Puppet file resource
# definition, combining the available parameters with ones computed internally
# (aligned with http://docs.fluentd.org/articles/plugin-management).
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
#   Used as basename (without .rb extension or directory path) when
#   generating the plugin file $path.
#
# [*source*]
#   Translates directly into the file $source parameter.
#
# [*target*]
#   Translates directly into the file $target parameter.
#
# === Examples:
#
#   fluent::plugin {'example1':
#     name => 'my_plugin',
#     source => 'puppet:///modules/custom/fluentd/plugin.rb',
#   }
#
#   fluent::plugin {'example2':
#     ensure => 'link',
#     target => '/opt/custom-fluentd-stuff/plugin.rb',
#   }
#
define fluent::plugin (
  $content = undef,
  $ensure = 'present',
  $source = undef,
  $target = undef,
) {

  include fluent
  include stdlib

  file {"fluent::plugin#$title":
    content => $content,
    ensure => $ensure,
    group => $fluent::group,
    mode => 0640,
    notify => Service['fluent'],
    owner => getparam(File['fluent'], 'owner'),
    path =>  "$fluent::directory/plugin/$name.rb",
    require => File["$fluent::directory/plugin"],
    source => $source,
    target => $target,
  }
}
