class ssh {
  package {'openssh-server': ensure => present}

  concat {'sshd_config':
    path => '/etc/ssh/sshd_config',
    owner => root,
    group => root,
    mode => 0644,
    require => Package['openssh-server']
  }

  concat::fragment {'sshd_config_template':
    target => 'sshd_config',
    source => 'puppet:///modules/ssh/sshd_config',
    order => '01',
  }

  service {'ssh':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    subscribe => Concat['sshd_config']
  }
}
