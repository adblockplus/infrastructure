# == Class: adblockplus::puppet
#
# Manage Puppet (https://github.com/puppetlabs/puppet) resources.
#
# === Parameters:
#
# [*ensure*]
#   General target policy for Puppet resources, supported values include
#   "present", "latest", "absent" and "purged".
#
# === Examples:
#
#   class {'adblockplus::puppet':
#     ensure => 'latest',
#   }
#
class adblockplus::puppet (
  $ensure = 'present',
) {

  # https://forge.puppet.com/puppetlabs/stdlib
  include stdlib

  # https://tickets.puppetlabs.com/browse/PUP-3655
  ensure_resource('file', '/var/lib/puppet/facts.d', {
    ensure => ensure_directory_state($ensure),
    group => 'root',
    mode => 0755,
    owner => 'root',
  })

  # http://stackoverflow.com/questions/22816946/
  ensure_resource('file', '/var/lib/puppet/facts.d/pup3665', {
    'content' => "#!/bin/sh\necho 'pup3665=workaround'\n\n",
    'ensure' => ensure_file_state($ensure),
    'group' => 'root',
    'mode' => 0755,
    'owner' => 'root',
  })

  File['/var/lib/puppet/facts.d'] -> File['/var/lib/puppet/facts.d/pup3665']
}
