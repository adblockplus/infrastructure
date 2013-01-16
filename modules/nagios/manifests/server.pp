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
}
