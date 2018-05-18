# == Class: adblockplus::legacy
#
# A container for migrating obsolete global resources, included with the
# adblockplus class. See http://hub.eyeo.com/issues/1541 for more information.
#
class adblockplus::legacy {

  # Formerly included with class statsclient
  user {'stats':
    ensure => 'absent',
  }

  # User resources cannot remove the associated $HOME directory
  file {'/home/stats':
    ensure => 'absent',
    force => true,
    recurse => true,
  }

  # http://hub.eyeo.com/issues/11294#note-3
  if $::lsbdistcodename == 'jessie' {

    # https://stackoverflow.com/questions/27341064/
    package {'python-pip':
      ensure => 'absent',
    }

    # http://setuptools.readthedocs.io/en/latest/easy_install.html
    package {'python-setuptools':
      before => Package['python-pip'],
      ensure => 'present',
    }

    # https://github.com/pypa/pip/issues/5247
    exec {'/usr/bin/easy_install pip==9.0.3':
      before => Package['python-pip'],
      creates => '/usr/local/bin/pip',
      require => Package['python-setuptools'],
    }
  }
  else {

    # https://pypi.org/project/pip/
    package {'python-pip':
      ensure => 'present',
    }
  }
}
