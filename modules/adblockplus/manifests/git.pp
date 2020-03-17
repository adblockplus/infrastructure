# == Class: adblockplus::git
#
# Manage git (https://www.git-scm.org/) resources.
#
# === Parameters:
#
# [*ensure*]
#   Either 'present', 'absent' or 'purged'.
#
# === Examples:
#
#   class {'adblockplus::git':
#      ensure => 'latest',
#   }
#
class adblockplus::git (
  $ensure = 'present',
  $package = 'git',
) {

  # https://forge.puppet.com/puppetlabs/stdlib
  include stdlib

  # https://forge.puppet.com/puppetlabs/stdlib#ensure_resource
  ensure_resource('package', $package, {
    ensure => $ensure,
  })
}
