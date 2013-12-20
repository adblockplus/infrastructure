class statsclient {
  user {'stats':
    ensure => present,
    home => '/home/stats',
    managehome => true,
  }

  file {'/home/stats/.ssh':
    ensure => directory,
    owner => stats,
    mode => 0600,
    require => User['stats'],
  }

  file {'/home/stats/.ssh/authorized_keys':
    ensure => present,
    owner => stats,
    mode => 0400,
    source => 'puppet:///modules/private/stats-authorized_keys',
  }

  class {'ssh':
    custom_configuration => 'Match User stats
        AllowTcpForwarding no
        X11Forwarding no
        AllowAgentForwarding no
        GatewayPorts no
        ForceCommand (echo $SSH_ORIGINAL_COMMAND | grep -qv /) && cat "/var/log/nginx/$SSH_ORIGINAL_COMMAND"',
  }

  cron {'mirrorstats':
    ensure => absent,
    user => stats,
  }
}
