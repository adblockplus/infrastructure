# == Class: docker
#
# Install docker (https://www.docker.com/)
#
# == Parameters:
#
# [*source*]
#  Overwrite the default apt::source used (given Class['apt'] is defined).
#
# [*package*]
#   Overwrite the default package options, to fine-tune the target version (i.e.
#   ensure => 'latest') or remove docker (ensure => 'absent' or 'purged')
#
# === Examples:
#
#   class {'docker':
#     package => {
#       ensure => 'latest',
#     },
#     source => {
#       location => 'https://apt.dockerproject.org/repo',
#       release => downcase("$::osfamily-$::lsbdistcodename"),
#       include_src => false,
#       key => '58118E89F3A912897C070ADBF76221572C52609D',
#       key_server => 'hkp://ha.pool.sks-keyservers.net:80',
#     }
#   }
#
class docker(
  $source = hiera('docker::source', {}),
  $package = hiera('docker::package', {}),
) {

  include stdlib

  ensure_resource('package', $title, merge({
    name => 'docker-engine',
    ensure => 'latest',
    provider => 'apt',
  }, $package))

  # Used as default $ensure parameter for most resources below
  $ensure = getparam(Package[$title], 'ensure') ? {
    /^(absent|purged|held)$/ => 'absent',
    default => 'present',
  }

  # Using ensure_*state functions
  if ensure_state($ensure) {

    service {'docker':
      ensure => running,
      require => Package['docker-engine'],
    }

  }

  # The only package provider recognized implicitly
  if getparam(Package[$title], 'provider') == 'apt' {

    ensure_resource('apt::source', $title, merge({
      before => Package['docker-engine'],
      location => 'https://apt.dockerproject.org/repo',
      release => downcase("$::osfamily-$::lsbdistcodename"),
      include_src => false,
      key => '58118E89F3A912897C070ADBF76221572C52609D',
      key_server => 'hkp://ha.pool.sks-keyservers.net:80',
    }, $source))

    Apt::Source[$title] -> Package[$title]
  }
}

