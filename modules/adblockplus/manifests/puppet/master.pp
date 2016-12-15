# == Class: adblockplus::puppet::master
#
# Manage Puppet (https://github.com/puppetlabs/puppet) master configuration.
#
# === Parameters:
#
# [*package*]
#   Custom parameters for the implicit Package['puppetmaster'] resource.
#
# [*service*]
#   Custom parameters for the Service['puppetmaster'] resource implicitly
#   defined the package is ensured to be neither "absent" nor "purged".
#
# === Examples:
#
#   class {'adblockplus::puppet::master':
#     package => {
#       'ensure' => 'present',
#       'name' => 'puppetmaster',
#     },
#     service => {
#       'ensure' => 'running',
#       'name' => 'puppetmaster',
#     },
#   }
#
class adblockplus::puppet::master (
  $package = hiera('adblockplus::puppet::master::package', {}),
  $service = hiera('adblockplus::puppet::master::service', {}),
) {

  include adblockplus::puppet
  include puppetmaster
  include stdlib

  # https://forge.puppet.com/puppetlabs/stdlib#ensure_resource
  ensure_resource('package', 'puppetmaster', merge({
    'ensure' => $adblockplus::puppet::ensure,
  }, $package))

  # https://forge.puppet.com/puppetlabs/stdlib#getparam
  if getparam(Package['puppet'], 'ensure') !~ /^(absent|purged)$/ {

    ensure_resource('service', 'puppetmaster', merge({
      'ensure' => 'running',
      'hasrestart' => true,
      'hasstatus' => true,
    }, $service))

    Service['puppetmaster'] <- Package['puppetmaster']
  }
}
