class nagios::server($vhost, $htpasswd_source, $admins) {
  include nginx, 'spawn-fcgi'

  package {['nagios3', 'nagios3-doc', 'nagios-nrpe-plugin', 'php5-cgi',
            'fcgiwrap', 'pnp4nagios']:
    ensure => present
  }

  file {'/etc/nginx/sites-enabled/default':
    ensure => 'absent',
    require => Package['nginx']
  }

  file {"/etc/nginx/sites-available/${vhost}":
    mode => 644,
    owner => root,
    group => root,
    content => template('nagios/site.erb'),
    require => Package['nginx'],
    notify => Service['nginx']
  }

  file {"/etc/nginx/sites-enabled/${vhost}":
    ensure => link,
    target => "/etc/nginx/sites-available/${vhost}",
    notify => Service['nginx']
  }

  spawn-fcgi::php-pool {'global':
    ensure => present,
    socket => '/tmp/php-fastcgi.sock'
  }
  
  service {'nagios3':
    ensure => running,
    enable => true,
    require => [Package['nagios3'], Package['pnp4nagios']]
  }

  service {'apache2':
    ensure => stopped,
    enable => false,
    before => Service['nagios3']
  }

  file {'/etc/nagios3/htpasswd.users':
    mode => 644,
    owner => root,
    group => root,
    source => $htpasswd_source
  }

  file {'/etc/nagios3/cgi.cfg':
    mode => 644,
    owner => root,
    group => root,
    content => template('nagios/cgi.cfg.erb'),
    require => Package['nagios3'],
    notify => Service['nagios3']
  }

  file {'/etc/nagios3/nagios.cfg':
    mode => 644,
    owner => root,
    group => root,
    source => 'puppet:///modules/nagios/nagios.cfg',
    require => Package['nagios3'],
    notify => Service['nagios3']
  }
  
  file {'/etc/nagios3/commands.cfg':
    mode => 644,
    owner => root,
    group => root,
    source => 'puppet:///modules/nagios/commands.cfg',
    require => Package['nagios3'],
    notify => Service['nagios3']
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
    notify => [File['/etc/nagios3/conf.d/hosts.cfg'], Service['nagios3']]
  }

  Nagios_hostgroup <| |> {
    target => '/etc/nagios3/conf.d/hostgroups.cfg',
    notify => [File['/etc/nagios3/conf.d/hostgroups.cfg'], Service['nagios3']]
  }

  Nagios_service <| |> {
    target => '/etc/nagios3/conf.d/services.cfg',
    notify => [File['/etc/nagios3/conf.d/services.cfg'], Service['nagios3']]
  }

  file {['/etc/nagios3/conf.d/hosts.cfg',
         '/etc/nagios3/conf.d/hostgroups.cfg',
         '/etc/nagios3/conf.d/services.cfg']:
    mode => 644
    require => Package['nagios3'],
    notify => Service['nagios3']
  }
}
