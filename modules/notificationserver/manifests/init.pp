class notificationserver {
  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  file {'/var/www':
    ensure => directory,
    owner => nginx,
    mode => 0755,
    require => Package['nginx']
  }

  file {'/var/www/notification':
    ensure => directory,
    owner => nginx,
    mode => 0755,
    require => Package['nginx']
  }

  file {'/var/www/notification/notification.json':
    ensure => file,
    owner => nginx,
    mode => 644,
    require => Package['nginx'],
    source => 'puppet:///modules/notificationserver/notification.json'
  }

  File {
    owner => root,
    group => root,
    mode => 0644,
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.key':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['notification.adblockplus.org'],
    mode => 0400,
    source => 'puppet:///modules/private/adblockplus.org_sslcert.key'
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.pem':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['notification.adblockplus.org'],
    mode => 0400,
    source => 'puppet:///modules/private/adblockplus.org_sslcert.pem'
  }

  nginx::hostconfig{'notification.adblockplus.org':
    source => 'puppet:///modules/notificationserver/notification.adblockplus.org',
    enabled => true
  }

  file {'/etc/logrotate.d/nginx_notification.adblockplus.org':
    ensure => file,
    mode => 0444,
    require => Nginx::Hostconfig['notification.adblockplus.org'],
    source => 'puppet:///modules/notificationserver/logrotate'
  }
}
