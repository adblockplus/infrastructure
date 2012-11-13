class adblockplusorg {
  class {'nginx':}

  nginx::resource::vhost {'adblockplus.org':
    ensure => present,
    www_root => '/var/www/adblockplus.org'
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

  file {['/var/www', '/var/www/adblockplus.org',
         '/var/www/adblockplus.org/anwiki', '/var/www/adblockplus.org/phproot']:
    ensure => 'directory'
  }

  file {'/usr/local/bin/deploy-anwiki':
    mode => 744,
    owner => root,
    group => root,
    source => 'puppet:///modules/adblockplusorg/deploy-anwiki'
  }
}
