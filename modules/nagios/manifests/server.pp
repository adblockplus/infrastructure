class nagios::server($vhost, $htpasswd_source, $admins) {
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

  file {'/etc/nginx/sites-enabled/default':
    ensure => absent,
    require => Package['nginx']
  }

  file {"/etc/nginx/sites-available/${vhost}":
    content => template('nagios/site.erb'),
    require => Package['nginx'],
    notify => Service['nginx']
  }

  file {"/etc/nginx/sites-enabled/${vhost}":
    ensure => link,
    target => "/etc/nginx/sites-available/${vhost}",
    notify => Service['nginx']
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.key':
    ensure => file,
    require => Package['nginx'],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.key'
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.pem':
    ensure => file,
    mode => 0400,
    require => Package['nginx'],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.pem'
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
    source => $htpasswd_source
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
    notify => [File['/etc/nagios3/conf.d/contacts.cfg'], Service['nagios3']]
  }

  Nagios_contactgroup <| |> {
    target => '/etc/nagios3/conf.d/contactgroups.cfg',
    notify => [File['/etc/nagios3/conf.d/contactgroups.cfg'], Service['nagios3']]
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

  file {['/etc/nagios3/conf.d/contacts.cfg',
         '/etc/nagios3/conf.d/contactgroups.cfg',
         '/etc/nagios3/conf.d/hosts.cfg',
         '/etc/nagios3/conf.d/hostgroups.cfg',
         '/etc/nagios3/conf.d/services.cfg']:
    require => Package['nagios3'],
    notify => Service['nagios3']
  }
}
