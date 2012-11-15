class adblockplusorg {
  package {['nginx']: ensure => 'present'}

  file {'/etc/nginx/sites-enabled/default':
    ensure => 'absent',
    require => Package['nginx']
  }

  file {'/etc/nginx/sites-available/adblockplus.org':
    mode => 644,
    owner => root,
    group => root,
    source => 'puppet:///modules/adblockplusorg/adblockplus.org',
    require => Package['nginx']
  }

  file {'/etc/nginx/sites-enabled/adblockplus.org':
    ensure => 'link',
    target => '/etc/nginx/sites-available/adblockplus.org'
  }

  service {'nginx':
    ensure => 'running',
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => File['/etc/nginx/sites-enabled/adblockplus.org']
  }

  file {'/usr/local/bin/deploy-anwiki':
    mode => 744,
    owner => root,
    group => root,
    source => 'puppet:///modules/adblockplusorg/deploy-anwiki'
  }

  exec {'/usr/local/bin/deploy-anwiki':
    subscribe => File['/usr/local/bin/deploy-anwiki']
  }

  class {'mysql::server':
    config_hash => {'root_password' => 'vagrant'}
  }

  mysql::db {'anwiki':
    user => 'anwiki',
    password => 'vagrant',
    host => 'localhost',
    grant => ['all'],
    require => Class['mysql::config']
  }
}
