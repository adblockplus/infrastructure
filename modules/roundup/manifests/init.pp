class roundup($tracker_name, $domain) inherits private::roundup {
  package {['roundup', 'python-mysqldb']: ensure => present}

  include nginx

  nginx::hostconfig {$domain:
    content => template('roundup/site.erb'),
    enabled => true
  }
  
  class {'mysql::server':
    config_hash => {'root_password' => $database_root_password}
  }

  mysql::db {'roundup':
    user => 'roundup',
    password => $database_password,
    host => 'localhost',
    grant => ['all'],
    require => Class['mysql::config']
  }

  file {'/etc/roundup/roundup-server.ini':
    ensure => present,
    content => template('roundup/roundup-server.ini.erb'),
    require => Package['roundup'],
    notify => Service['roundup']
  }

  $tracker_home = "/var/lib/roundup/trackers/${tracker_name}"

  Exec {
    path => ['/bin', '/usr/bin'],
  }

  exec {'install':
    command => "roundup-admin -i ${tracker_home} install classic mysql",
    onlyif => "test ! -d ${tracker_home}",
    require => Package['roundup', 'python-mysqldb']
  }

  file {"${tracker_home}/config.ini":
    ensure => present,
    content => template('roundup/config.ini.erb'),
    require => Exec['install'],
    notify => Service['roundup']
  }

  service {'roundup':
    ensure => running,
    hasstatus => false
  }
  
  $db_path = "${tracker_home}/db"

  exec {'initialise':
    command => "bash -c 'echo y | roundup-admin -i ${tracker_home} initialise ${admin_password}'",
    onlyif => "test ! -d ${db_path}/lock",
    require => [Package['roundup'], Mysql::Db['roundup']],
    notify => File[$db_path]
  }

  file {$db_path:
    owner => 'roundup',
    notify => Service['roundup']
  }
}
