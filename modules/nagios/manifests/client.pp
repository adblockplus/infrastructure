class nagios::client($server_ip) {
  package {'nagios-nrpe-server': ensure => present}

  file {'/etc/nagios/nrpe.cfg':
    mode => 644,
    owner => root,
    group => root,
    content => template('nagios/nrpe.cfg.erb'),
    require => Package['nagios-nrpe-server']
  }
  
  service {'nagios-nrpe-server':
    ensure => running,
    enable => true,
    subscribe => File['/etc/nagios/nrpe.cfg']
  }
}
