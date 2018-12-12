# == Class: adblockplus::mercurial::extension::hggit
#
# See http://hub.eyeo.com/issues/9024
# This class should be obsolete when puppet is => 4.1.0 due `install_options`
# being included for pip provider.
#
# [*ensure*]
#   General resource policy, i.e. "present" or "absent".
#
class adblockplus::mercurial::extension::hggit (
  $ensure = '0.8.9',
) {

  $dependencies = [
    'libffi-dev',
    'libssl-dev',
  ]

  ensure_packages($dependencies)

  exec {'upgrade setuptools':
    command => '/usr/local/bin/pip install --upgrade setuptools',
    require => Package[$dependencies],
  }

  exec {'upgrade urllib3':
    command => '/usr/local/bin/pip install --upgrade urllib3',
    require => Package[$dependencies],
  }

  adblockplus::mercurial::extension {'hggit':
    package => {
      ensure => $ensure,
      name => 'hg-git',
      provider => 'pip',
    },
    require => Exec['upgrade urllib3'],
  }
}

