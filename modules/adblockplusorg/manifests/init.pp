class adblockplusorg {
  package {['nginx', 'spawn-fcgi', 'php5-cgi']: ensure => 'present'}

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

  file {'/etc/init.d/php-fastcgi':
    mode => 755,
    owner => root,
    group => root,
    source => 'puppet:///modules/adblockplusorg/php-fastcgi-init'
  }

  file {'/etc/default/php-fastcgi':
    mode => 755,
    owner => root,
    group => root,
    source => 'puppet:///modules/adblockplusorg/php-fastcgi-default'
  }

  service {'php-fastcgi':
    ensure => 'running',
    enable => true,
    hasrestart => true,
    require => [Package['spawn-fcgi'], Package['php5-cgi']],
    subscribe => [File['/etc/init.d/php-fastcgi'],
                  File['/etc/default/php-fastcgi']]
  }

  file {'/usr/local/bin/deploy-anwiki':
    mode => 744,
    owner => root,
    group => root,
    source => 'puppet:///modules/adblockplusorg/deploy-anwiki'
  }

  file {'/var/www/adblockplus.org/httpdocs':
    ensure => 'directory',
    recurse => true
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
    before => File['/var/www/adblockplus.org/phproot/_anwiki-override.inc.php']
  }

  file {'/var/www/adblockplus.org/phproot/_anwiki-override.inc.php':
    source => 'puppet:///modules/adblockplusorg/_anwiki-override.inc.php'
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
