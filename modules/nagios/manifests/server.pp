class nagios::server($htpasswd_source) {
  package {['nagios3', 'nagios3-doc']:
    ensure => present
  }

  file {'/etc/nagios3/htpasswd.users':
    mode => 644,
    owner => root,
    group => root,
    source => $htpasswd_source
  }
  
  Nagios_host <| |> {
    target => '/etc/nagios3/conf.d/hosts_nagios2.cfg',
    notify => Service['nagios3']
  }

  file {'/etc/nagios3/conf.d/hosts_nagios2.cfg': mode => 644}

  Nagios_hostgroup <| |> {
    target => '/etc/nagios3/conf.d/hostgroups_nagios2.cfg',
    notify => Service['nagios3']
  }

  service {'nagios3':
    ensure => running,
    enable => true
  }
}
