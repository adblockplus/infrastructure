class adblockplusorg {
  package {['nginx', 'php5-cgi', 'php5-mysql']: ensure => 'present'}

  Package['php5-cgi'] -> Package['php5-mysql']

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
    subscribe => File['/etc/nginx/sites-available/adblockplus.org']
  }

  file {'/usr/local/bin/deploy-anwiki':
    mode => 744,
    owner => root,
    group => root,
    source => 'puppet:///modules/adblockplusorg/deploy-anwiki'
  }

  file {['/var', '/var/www', '/var/www/adblockplus.org',
         '/var/www/adblockplus.org/httpdocs']:
    ensure => 'directory'
  }

  file {'/var/www/adblockplus.org/httpdocs/index.php':
    mode => 744,
    owner => 'www-data',
    group => 'www-data',
    content => ''
  }

  file {'/var/www/adblockplus.org/httpdocs/default-static':
    ensure => 'link',
    target => '/var/www/adblockplus.org/anwiki/default-static'
  }

  file {'/var/www/adblockplus.org/httpdocs/_override-static':
    ensure => 'link',
    target => '/var/www/adblockplus.org/anwiki/_override-static'
  }

  file {'/var/www/adblockplus.org/httpdocs/_addons-static':
    ensure => 'link',
    target => '/var/www/adblockplus.org/anwiki/_addons-static'
  }

  exec {'/usr/local/bin/deploy-anwiki':
    subscribe => File['/usr/local/bin/deploy-anwiki'],
    before => [
      File['/var/www/adblockplus.org/phproot/_anwiki-override.inc.php'],
      File['/var/www/adblockplus.org/anwiki/_override/drivers/sessionsdrivers/sessionsdriver_mysql/sessionsdriver_mysql.cfg.php'],
      File['/var/www/adblockplus.org/anwiki/_override/drivers/usersdrivers/usersdriver_mysql/usersdriver_mysql.cfg.php'],
      File['/var/www/adblockplus.org/anwiki/_override/drivers/storagedrivers/storagedriver_mysql/storagedriver_mysql.cfg.php']
    ]
  }

  file {'/var/www/adblockplus.org/phproot/_anwiki-override.inc.php':
    source => 'puppet:///modules/adblockplusorg/_anwiki-override.inc.php',
    owner => 'www-data',
    group => 'www-data'
  }

  file {'/var/www/adblockplus.org/anwiki/_override/drivers/sessionsdrivers/sessionsdriver_mysql/sessionsdriver_mysql.cfg.php':
    source => 'puppet:///modules/adblockplusorg/anwiki.cfg.php',
    owner => 'www-data',
    group => 'www-data'
  }

  file {'/var/www/adblockplus.org/anwiki/_override/drivers/usersdrivers/usersdriver_mysql/usersdriver_mysql.cfg.php':
    source => 'puppet:///modules/adblockplusorg/anwiki.cfg.php',
    owner => 'www-data',
    group => 'www-data'
  }

  file {'/var/www/adblockplus.org/anwiki/_override/drivers/storagedrivers/storagedriver_mysql/storagedriver_mysql.cfg.php':
    source => 'puppet:///modules/adblockplusorg/anwiki.cfg.php',
    owner => 'www-data',
    group => 'www-data'
  }

  package {'php5-fpm':
    ensure => absent,
    require => Class['mysql::server']
  }

  class {'spawn-fcgi':}

  # No PHP_FCGI_MAX_REQUESTS=100 in that something :(
  spawn-fcgi::php-pool {'global':
    ensure => present,
    socket => '/tmp/php-fastcgi.sock',
    children => '3'
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
