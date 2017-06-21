class postfix {
  package {'postfix': ensure => present}

  file {'/etc/postfix/main.cf':
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    source => 'puppet:///modules/postfix/main.cf',
    require => Package['postfix'],
    notify => Service['postfix']
  }

  service {'postfix':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true
  }
}
