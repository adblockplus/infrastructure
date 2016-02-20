# == Class: buildbot
#
# Manage Buildbot (https://buildbot.net/) master and slave setups.
#
# Class buildbot acts as the root namespace for the buildbot integration
# with Puppet, while also providing a variety of setup parameters that can
# be used to adjust the software setup.
#
# It defines a set of virtual resources titled 'buildmaster' and 'buildslave'.
# Those are realized implicitly when required by any of the various entities
# within the module, but may become realized explicitely when necessary:
#
# - Concat[]: The 'buildmaster' and 'buildslave' system daemon configuration
# - Concat::Fragment[]: The respective root or configuration head fragment
# - File[]: The anchestor of default for master and slave $basedir resources
# - Service[]: The actual services running the master and slave instances
#
# Note, however, that the respective instances are rather implementation
# specific and thus may become subject to change in the future.
#
# === Parameters:
#
# [*master_service*]
#   The 'buildmaster' service status to ensure, if any.
#
# [*slave_service*]
#   The 'buildslave' service status to ensure, if any.
#
# === Examples:
#
#   class {'buildbot':
#     master_service => 'running',
#   }
#
class buildbot (
  $master_service = undef,
  $slave_service = undef,
) {

  $master_config = '/etc/default/buildmaster'
  $master_directory = '/var/buildmaster'
  $master_packages = ['buildbot']
  $master_runner = '/usr/bin/buildbot'
  $master_user = 'buildbot'

  $slave_config = '/etc/default/buildslave'
  $slave_directory = '/var/buildslave'
  $slave_packages = ['buildbot-slave']
  $slave_runner = '/usr/bin/buildslave'
  $slave_user = 'buildbot'

  @concat {
    'buildmaster':
      owner => $master_user,
      path => $master_config,
      require => Package[$master_packages];
    'buildslave':
      owner => $slave_user,
      path => $slave_config,
      require => Package[$slave_packages];
  }

  @concat::fragment {
    'buildmaster':
      content => template('buildbot/buildmaster.erb'),
      order => 0,
      target => 'buildmaster';
    'buildslave':
      content => template('buildbot/buildslave.erb'),
      order => 0,
      target => 'buildslave';
  }

  @file {
    $master_directory:
      ensure => 'directory',
      owner => $master_user,
      require => Package[$master_packages];
    $slave_directory:
      ensure => 'directory',
      owner => $slave_user,
      require => Package[$slave_packages];
  }

  Service {
    hasrestart => true,
    hasstatus => false,
  }

  @service {
    'buildmaster':
      ensure => $master_service ? {
        /^(running|started|true)$/ => 'running',
        default => 'stopped',
      },
      pattern => "^$master_user.*python.*$master_runner",
      require => Package[$master_packages];
    'buildslave':
      ensure => $slave_service ? {
        /^(running|started|true)$/ => 'running',
        default => 'stopped',
      },
      pattern => "^$slave_user.*python.*$slave_runner",
      require => Package[$slave_packages];
  }

  Service['buildmaster'] <~ Exec <|creates == $master_config|>
  Service['buildmaster'] <~ File <|path == $master_config|>
  Service['buildmaster'] ~>

  Service['buildslave'] <~ Exec <|creates == $slave_config|>
  Service['buildslave'] <~ File <|path == $slave_config|>

  if $master_service != undef {
    ensure_packages($master_packages)
    realize(Service['buildmaster'])
  }

  if $slave_service != undef {
    ensure_packages($slave_packages)
    realize(Service['buildslave'])
  }
}
