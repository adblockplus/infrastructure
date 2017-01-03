# == Class: adblockplus::puppet::agent
#
# Manage Puppet (https://github.com/puppetlabs/puppet) agent configuration.
#
# === Parameters:
#
# [*package*]
#   Custom parameters for the implicit Package['puppet'] resource.
#
# [*service*]
#   Custom parameters for the Service['puppet'] resource implicitly defined
#   if Package['puppet'] is ensured to be neither "absent" nor "purged".
#
# === Examples:
#
#   class {'adblockplus::puppet::agent':
#     package => {
#       'ensure' => 'present',
#       'name' => 'puppet',
#     },
#     service => {
#       'ensure' => 'stopped',
#       'name' => 'puppet',
#     },
#   }
#
class adblockplus::puppet::agent (
  $package = hiera('adblockplus::puppet::agent::package', {}),
  $service = hiera('adblockplus::puppet::agent::service', {}),
) {

  include adblockplus::puppet
  include stdlib

  # https://forge.puppet.com/puppetlabs/stdlib#ensure_resource
  ensure_resource('package', 'puppet', merge({
    'ensure' => $adblockplus::puppet::ensure,
  }, $package))

  # https://forge.puppet.com/puppetlabs/stdlib#getparam
  if ensure_state(Package['puppet']) {

    ensure_resource('service', 'puppet', merge({
      'ensure' => 'stopped',
      'hasrestart' => true,
      'hasstatus' => true,
    }, $service))

    Service['puppet'] <- Package['puppet']
  }
}
