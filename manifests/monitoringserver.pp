node default {
  include base

  package {['nagios3', 'nagios3-doc']:
    ensure => present
  }

  file {'/etc/nagios3/htpasswd.users':
    mode => 644,
    owner => root,
    group => root,
    source => 'puppet:///modules/private/nagios3-htpasswd'
  }
}
