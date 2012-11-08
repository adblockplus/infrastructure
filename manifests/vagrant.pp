node default {
  include base, nginx

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
