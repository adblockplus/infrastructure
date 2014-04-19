class nagios::server(
    $domain,
    $certificate,
    $private_key,
    $is_default=false,
    $htpasswd_source,
    $admins
  ) {

  File {
    owner  => 'root',
    group  => 'root',
    mode   => 0644
  }

  include nginx, 'spawn-fcgi'

  package {['nagios3', 'nagios3-doc', 'nagios-nrpe-plugin', 'php5-cgi',
            'fcgiwrap', 'pnp4nagios']:
    ensure => present
  }

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/nagios/site.conf',
    is_default => $is_default,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_monitoring'
  }

  spawn-fcgi::php-pool {'global':
    ensure => present,
    socket => '/tmp/php-fastcgi.sock',
    children => '3'
  }

  service {'nagios3':
    ensure => running,
    enable => true,
    require => [Package['nagios3'], Package['pnp4nagios']]
  }

  service {'apache2':
    ensure => stopped,
    enable => false,
    require => Package['nagios3'],
    before => Service['nagios3']
  }

  file {'/etc/nagios3/htpasswd.users':
    source => $htpasswd_source,
    require => Package['nagios3']
  }

  file {'/etc/nagios3/cgi.cfg':
    content => template('nagios/cgi.cfg.erb'),
    require => Package['nagios3'],
    notify => Service['nagios3']
  }

  file {'/etc/nagios3/nagios.cfg':
    source => 'puppet:///modules/nagios/nagios.cfg',
    require => Package['nagios3'],
    notify => Service['nagios3']
  }

  file {'/etc/nagios3/commands.cfg':
    source => 'puppet:///modules/nagios/commands.cfg',
    require => Package['nagios3'],
    notify => Service['nagios3']
  }

  file {'/etc/nagios3/conf.d/generic-host.cfg':
    source => 'puppet:///modules/nagios/generic-host.cfg',
    require => Package['nagios3'],
    notify => Service['nagios3']
  }

  file {'/etc/nagios3/conf.d/generic-service.cfg':
    source => 'puppet:///modules/nagios/generic-service.cfg',
    require => Package['nagios3'],
    notify => Service['nagios3']
  }

  file {['/etc/nagios3/conf.d/contacts_nagios2.cfg',
         '/etc/nagios3/conf.d/extinfo_nagios2.cfg',
         '/etc/nagios3/conf.d/generic-host_nagios2.cfg',
         '/etc/nagios3/conf.d/generic-service_nagios2.cfg',
         '/etc/nagios3/conf.d/hosts_nagios2.cfg',
         '/etc/nagios3/conf.d/hostgroups_nagios2.cfg',
         '/etc/nagios3/conf.d/localhost_nagios2.cfg',
         '/etc/nagios3/conf.d/services_nagios2.cfg']:
    ensure => absent
  }

  resources {['nagios_contact', 'nagios_contactgroup', 'nagios_host',
              'nagios_hostgroup', 'nagios_service']:
    purge => true
  }

  Nagios_contact <| |> {
    target => '/etc/nagios3/conf.d/contacts.cfg',
    require => Package['nagios3'],
    notify => [File['/etc/nagios3/conf.d/contacts.cfg'], Service['nagios3']]
  }

  Nagios_contactgroup <| |> {
    target => '/etc/nagios3/conf.d/contactgroups.cfg',
    require => Package['nagios3'],
    notify => [File['/etc/nagios3/conf.d/contactgroups.cfg'], Service['nagios3']]
  }

  Nagios_command <| |> {
    target => '/etc/nagios3/conf.d/commands.cfg',
    require => Package['nagios3'],
    notify => [File['/etc/nagios3/conf.d/commands.cfg'], Service['nagios3']]
  }

  Nagios_host <| |> {
    target => '/etc/nagios3/conf.d/hosts.cfg',
    require => Package['nagios3'],
    notify => [File['/etc/nagios3/conf.d/hosts.cfg'], Service['nagios3']]
  }

  Nagios_hostgroup <| |> {
    target => '/etc/nagios3/conf.d/hostgroups.cfg',
    require => Package['nagios3'],
    notify => [File['/etc/nagios3/conf.d/hostgroups.cfg'], Service['nagios3']]
  }

  Nagios_service <| |> {
    target => '/etc/nagios3/conf.d/services.cfg',
    require => Package['nagios3'],
    notify => [File['/etc/nagios3/conf.d/services.cfg'], Service['nagios3']]
  }

  file {['/etc/nagios3/conf.d/contacts.cfg',
         '/etc/nagios3/conf.d/contactgroups.cfg',
         '/etc/nagios3/conf.d/commands.cfg',
         '/etc/nagios3/conf.d/hosts.cfg',
         '/etc/nagios3/conf.d/hostgroups.cfg',
         '/etc/nagios3/conf.d/services.cfg']:
    require => Package['nagios3'],
    notify => Service['nagios3']
  }
}
