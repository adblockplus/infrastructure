class nagios::server(
    $domain,
    $certificate,
    $private_key,
    $is_default=false,
    $htpasswd_source,
    $admins,
    $zone,
    $contacts = hiera('nagios::server::contacts', {}),
    $contactgroups = hiera('nagios::server::contactgroups', {}),
    $commands = hiera('nagios::server::commands', {}),
    $services = hiera('nagios::server::services', {}),
    $hosts = hiera('nagios::server::hosts', {}),
    $hostgroups = hiera('nagios::server::hostgroups', {}),
  ) {

  File {
    owner  => 'root',
    group  => 'root',
    mode   => 0644
  }

  include nginx
  include spawn_fcgi

  package {['nagios3', 'nagios3-doc', 'nagios-nrpe-plugin', 'php5-cgi',
            'fcgiwrap', 'pnp4nagios']:
    ensure => present
  }

  if $::operatingsystem == 'Debian' {
    class { 'apt::backports':
      release  => 'jessie',
      location => 'http://ftp.debian.org/debian',
    }
  }

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/nagios/site.conf',
    is_default => $is_default,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_monitoring'
  }

  spawn_fcgi::php_pool {'global':
    ensure => present,
    socket => '/tmp/php-fastcgi.sock',
    children => '3',
    require => Package['php5-cgi']
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
    ensure => absent,
    require => Package['nagios3'],
    before => Service['nagios3']
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
    notify => [File['/etc/nagios3/conf.d/hosts.cfg'], Service['nagios3']]
  }
  <-
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

  create_resources(nagios_contact, $contacts)
  create_resources(nagios_contactgroup, $contactgroups)
  create_resources(nagios_command, $commands)
  create_resources(nagios_service, $services)
  create_resources(nagios_host, $hosts)
  create_resources(nagios_hostgroup, $hostgroups)
}
