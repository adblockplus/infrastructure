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

  file {['/etc/nagios3/conf.d/extinfo_nagios2.cfg',
         '/etc/nagios3/conf.d/hosts_nagios2.cfg',
         '/etc/nagios3/conf.d/hostgroups_nagios2.cfg',
         '/etc/nagios3/conf.d/localhost_nagios2.cfg',
         '/etc/nagios3/conf.d/services_nagios2.cfg']:
    ensure => absent
  }

  resources {['nagios_host', 'nagios_hostgroup', 'nagios_service']:
    purge => true
  }
  
  Nagios_host <| |> {
    target => '/etc/nagios3/conf.d/hosts.cfg',
    notify => [Service['nagios3'], File['/etc/nagios3/conf.d/hosts.cfg']]
  }

  Nagios_hostgroup <| |> {
    target => '/etc/nagios3/conf.d/hostgroups.cfg',
    notify => [Service['nagios3'], File['/etc/nagios3/conf.d/hosts.cfg']]
  }

  Nagios_service <| |> {
    target => '/etc/nagios3/conf.d/services.cfg',
    notify => [Service['nagios3'], File['/etc/nagios3/conf.d/hosts.cfg']]
  }

  service {'nagios3':
    ensure => running,
    enable => true,
    require => Package['nagios3']
  }

  file {['/etc/nagios3/conf.d/hosts.cfg',
         '/etc/nagios3/conf.d/hostgroups.cfg',
         '/etc/nagios3/conf.d/services.cfg']:
    mode => 644
  }
}
