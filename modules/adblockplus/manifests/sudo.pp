# == Class: adblockplus::sudo
#
# Mixin class to ensure super-user privileges can only be acquired through
# the sudo(8) system daemon.
#
# === Parameters:
#
# [*ensure*]
#   Whether associated resources are meant to be 'present' or 'absent'.
#
# === Examples:
#
#   class {'adblockplus::sudo':
#     ensure => 'present',
#   }
#
class adblockplus::sudo (
  $ensure = 'present',
) {

  # https://forge.puppetlabs.com/puppetlabs/stdlib
  include stdlib

  # Obligatory despite the package being included with all environments
  ensure_packages(['sudo'])

  # User root must not be able to login via password
  ensure_resource('user', 'root', {'password' => '*'})

  # The root account must not be accessible directly via SSH
  file {'/root/.ssh/authorized_keys':
    ensure => 'absent',
  }

  # Prerequisite for the accompanying kick.py and run.py scripts
  file {'/etc/sudoers.d/puppet':
    ensure => $ensure,
    group => 'root',
    mode => 0440,
    owner => 'root',
    require => Package['sudo'],
    source => 'puppet:///modules/adblockplus/sudoers/puppet'
  }
}
