class adblockplusorg {
  class {'nginx':}

  nginx::resource::vhost {'adblockplus.org':
    ensure => present,
    www_root => '/var/www/adblockplus.org'
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
