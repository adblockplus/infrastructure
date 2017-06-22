class ssh(
  $agent_forwarding = hiera('ssh::agent_forwarding', false),
  $tcp_forwarding = hiera('ssh::tcp_forwarding', false),
) {

  ensure_packages([
    'openssh-client',
    'openssh-server',
  ])

  package {['libssl1.0.0', 'openssl']:
    ensure => 'latest',
  }

  concat {'sshd_config':
    path => '/etc/ssh/sshd_config',
    owner => root,
    group => root,
    mode => '0644',
    require => Package['openssh-server']
  }

  concat::fragment {'sshd_config_template':
    target => 'sshd_config',
    content => template('ssh/sshd_config.erb'),
    order => '01',
  }

  file {'ssh_config':
    content => template('ssh/ssh_config.erb'),
    group => 'root',
    mode => '0644',
    owner => 'root',
    path => '/etc/ssh/ssh_config',
    require => Package['openssh-client'],
  }

  service {'ssh':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
    subscribe => Concat['sshd_config']
  }

  Service['ssh'] <~ Package['libssl1.0.0']
  Service['ssh'] <~ Package['openssl']
}
