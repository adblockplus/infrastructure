class ssh ($custom_configuration = '') {
  package {'openssh-server': ensure => present}

  file {'/etc/ssh/sshd_config':
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template('ssh/sshd_config.erb'),
    require => Package['openssh-server']
  }

  service {'ssh':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    subscribe => File['/etc/ssh/sshd_config']
  }
}
