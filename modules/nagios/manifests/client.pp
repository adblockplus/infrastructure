class nagios::client($server_address) {

  ensure_packages([
    'nagios-nrpe-server',
    'sudo',
    'tcpdump',
  ])

  file {'/etc/nagios/nrpe.cfg':
    mode => 644,
    owner => root,
    group => root,
    content => template('nagios/nrpe.cfg.erb'),
    require => Package['nagios-nrpe-server'],
    notify => Service['nagios-nrpe-server']
  }

  service {'nagios-nrpe-server':
    ensure => running,
    enable => true,
    subscribe => File['/etc/nagios/nrpe.cfg']
  }

  file {'/etc/sudoers.d/nagios':
    ensure => present,
    owner => root,
    group => root,
    mode => 0440,
    source => 'puppet:///modules/nagios/sudoers',
    require => Package['sudo'],
  }

  file {'/usr/lib/nagios/plugins/check_bandwidth':
    ensure => present,
    mode => 755,
    owner => root,
    group => root,
    source => 'puppet:///modules/nagios/check_bandwidth',
    require => [
      Package['nagios-nrpe-server'],
      File['/etc/sudoers.d/nagios'],
    ]
  }

  file {'/usr/lib/nagios/plugins/check_connections':
    ensure => present,
    mode => 755,
    owner => root,
    group => root,
    source => 'puppet:///modules/nagios/check_connections',
    require => Package['nagios-nrpe-server']
  }

  file {'/usr/lib/nagios/plugins/check_memory':
    ensure => present,
    mode => 755,
    owner => root,
    group => root,
    source => 'puppet:///modules/nagios/check_memory',
    require => Package['nagios-nrpe-server']
  }
}
