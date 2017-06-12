# == Class: adblockplus
#
# The adblockplus class and the associated adblockplus:: namespace are
# used to integrate Puppet modules with each other, in order to assemble
# the setups used by the Adblock Plus project.
#
# === Parameters:
#
# [*authority*]
#   The authorative domain or zone associated with the current environment.
#
# [*hosts*]
#   A hash of adblockplus::host $name => $parameter items to set up in this
#   context, i.e. via Hiera.
#
# [*users*]
#   A hash of adblockplus::user $name => $parameter items to set up in this
#   context, i.e. via Hiera.
#
# [*packages*]
#   An array of adblockplus::packages items to set up in this context,
#   i.e. via Hiera.
#
# === Examples:
#
#   class {'adblockplus':
#     hosts => {
#       'node1' => {
#         # see adblockplus::host
#       },
#     },
#     users => {
#       'pinocchio' => {
#         # see adblockplus::user
#       },
#     },
#   }
#
class adblockplus (
  $authority = hiera('adblockplus::authority', 'adblockplus.org'),
  $hosts = hiera_hash('adblockplus::hosts', {}),
  $packages = hiera_array('adblockplus::packages', []),
  $users = hiera_hash('adblockplus::users', {}),
) {

  include postfix
  include ssh
  include stdlib

  # See https://issues.adblockplus.org/ticket/3575#comment:2
  class {'logrotate':
    stage => 'runtime',
  }

  # Used as internal constant within adblockplus::* resources
  $directory = '/var/adblockplus'

  # A common location for directories specific to the adblockplus:: setups,
  # managed via Puppet, but accessible by all users with access to the system
  @file {$directory:
    ensure => 'directory',
    mode => 0755,
    owner => 'root',
  }

  # A common time-zone shared by all hosts provisioned eases synchronization
  # and debugging, i.e. log-file review and similar tasks, significantly
  file {
    '/etc/timezone':
      content => 'UTC',
      ensure => 'present',
      group => 'root',
      mode => 0644,
      notify => Service['cron'],
      owner => 'root';
    '/etc/localtime':
      ensure => 'link',
      target => '/usr/share/zoneinfo/UTC',
      notify => Service['cron'];
  }

  # Explicit resource required only to ensure cron(8) is running;
  # there is no real requirement for a rationship with another resource
  service {'cron':
    ensure => 'running',
    enable => true,
  }

  $cron_env = hiera('cron::environment', [])

  file { '/etc/crontab':
    ensure => 'present',
    content => template('adblockplus/crontab.erb'),
    owner => 'root',
    group => 'root',
    mode => 0644,
  }

  # Work around https://issues.adblockplus.org/ticket/3479
  if $::environment == 'development' {

    file {
      '/etc/ssh/ssh_host_rsa_key':
        source => 'puppet:///modules/adblockplus/development_host_rsa_key',
        mode => 600,
        notify => Service['ssh'];
      '/etc/ssh/ssh_host_rsa_key.pub':
        source => 'puppet:///modules/adblockplus/development_host_rsa_key.pub',
        mode => 644;
    }
  }

  # Fix implicit package dependency Class['apt'] does not properly handle
  Exec['apt_update'] -> Package<|title != 'python-software-properties'|>

  # https://issues.adblockplus.org/ticket/3574#comment:19
  ensure_packages($packages)

  # https://projects.puppetlabs.com/issues/4145
  ensure_resource('file', '/etc/ssh/ssh_known_hosts', {
    ensure => 'present',
    mode => 0644,
  })

  # See modules/adblockplus/manifests/host.pp
  create_resources('adblockplus::host', $hosts)

  # See modules/adblockplus/manifests/user.pp
  create_resources('adblockplus::user', $users)
}
