node default {
  include base, nginx
  
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
}
