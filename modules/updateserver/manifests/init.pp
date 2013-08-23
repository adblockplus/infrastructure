class updateserver {
  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  class {'statsclient':
    log_path => '/var/log/nginx/access_log_update.1.gz',
  }

  File {
    owner => root,
    group => root
  }

  file {'/var/www':
    ensure => directory,
    mode => 0755,
    require => Package['nginx']
  }

  file {'/var/www/update':
    ensure => directory,
    mode => 0755
  }

  file {'/var/www/update/adblockplusie':
    ensure => directory,
    mode => 0755
  }

  file {'/var/www/update/adblockplusie/update.json':
    ensure => file,
    source => 'puppet:///modules/updateserver/adblockplusie/update.json',
    mode => 0644
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.key':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['update.adblockplus.org'],
    mode => 0400,
    source => 'puppet:///modules/private/adblockplus.org_sslcert.key'
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.pem':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['update.adblockplus.org'],
    mode => 0400,
    source => 'puppet:///modules/private/adblockplus.org_sslcert.pem'
  }

  nginx::hostconfig{'update.adblockplus.org':
    source => 'puppet:///modules/updateserver/update.adblockplus.org',
    enabled => true
  }

  file {'/etc/logrotate.d/nginx_update.adblockplus.org':
    ensure => file,
    mode => 0444,
    require => Nginx::Hostconfig['update.adblockplus.org'],
    source => 'puppet:///modules/updateserver/logrotate'
  }
}
