class ssh(
  $agent_forwarding = hiera('ssh::agent_forwarding', false),
  $tcp_forwarding = hiera('ssh::tcp_forwarding', false),
) {

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
    content => template('ssh/sshd_config.erb'),
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
