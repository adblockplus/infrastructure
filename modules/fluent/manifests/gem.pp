# == Type: fluent::gem
#
# Maintain Fluentd (plugin) gems.
#
# Type fluentd::gem is a thin layer around a single Puppet package resource
# definition, combining the available parameters with ones computed internally
# (aligned with http://docs.fluentd.org/articles/plugin-management#fluent-gem)
# and determining the proper default package provider (module fluent includes
# specialized providers using the gem command that ships with Fluentd, see the
# *.rb files in modules/fluent/lib/puppet/provider/package for details).#
#
# === Parameters:
#
# [*ensure*]
#   Translates directly into the package $ensure parameter.
#
# [*name*]
#   Translates directly into the package $name parameter.
#
# [*provider*]
#   Translates directly into the package $provider parameter.
#
# === Examples:
#
#   fluent::gem {[
#     'fluent-plugin-secure-forward',
#     'fluent-plugin-grep',
#   ]:
#     ensure => 'latest',
#   }
#
define fluent::gem (
  $ensure = 'present',
  $provider = getparam(Package['fluent'], 'name') ? {
    /\btd[_\-]/ => 'td_agent_gem',
    default => 'fluent_gem',
  }
) {

  include fluent
  include stdlib

  # Returns undef if Service['fluent'] is not defined
  $notify = getparam(Service['fluent'], 'ensure') ? {
    /^(running|true)$/ => Service['fluent'],
    default => [],
  }

  package {$title:
    ensure => $ensure,
    name => $name,
    notify => $notify,
    provider => $provider,
    require => Package['fluent'],
  }
}
