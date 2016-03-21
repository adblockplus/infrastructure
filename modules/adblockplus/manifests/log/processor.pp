# == Class: adblockplus::log::processor
#
# A mixin class that defines a set of additional Hiera keys for Fluentd,
# each of which is examined using function hiera_hash(). This allows for
# fine-tuning the setup via YAML, but will only be supported as long as
# Fluentd is actually the sofware behind adblockplus::log resources. This
# is unlikely to change though, or at least there are no such plans yet.
#
# === Hiera:
#
# [*fluent::configs*]
#   A hash of zero or more $title => $parameters items for the definition
#   of fluentd::config resources via YAML.
#
# [*fluent::gems*]
#   A hash of zero or more $title => $parameters items for the definition
#   of fluent_gem resources via YAML.
#
# [*fluent::plugins*]
#   A hash of zero or more $title => $parameters items for the definition
#   of fluent::plugin resources via YAML.
#
# === Examples:
#
#   # Does not imply inclusion of any other adblockplus::* manifest
#   include adblockplus::log::processor
#
class adblockplus::log::processor {

  $fluent_configs = hiera_hash('fluent::configs', {})
  create_resources('fluent::config', $fluent_configs)

  $fluent_gems = hiera_hash('fluent::gems', {})
  create_resources('fluent::gem', $fluent_gems)

  $fluent_plugins = hiera_hash('fluent::plugins', {})
  create_resources('fluent::plugin', $fluent_plugins)
}
