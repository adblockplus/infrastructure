class notificationserver {
  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  class {'statsclient':
    log_path => '/var/log/nginx/access_log_notification.1.gz',
    custom_sitescriptsini_source => 'puppet:///modules/notificationserver/sitescripts.ini'
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

  exec { "fetch_notifications":
    command => "hg clone --noupdate https://hg.adblockplus.org/notifications /opt/notifications && chown -R nginx /opt/notifications",
    path => ["/usr/bin/", "/bin/"],
    require => Package['mercurial'],
    onlyif => "test ! -d /opt/notifications"
  }

  cron {"update_notifications":
    ensure => present,
    command => "python -m sitescripts.management.bin.generateNotifications",
    environment => ['MAILTO=admins@adblockplus.org,root', 'PYTHONPATH=/opt/sitescripts'],
    user => nginx,
    minute => '*/10',
    require => [
      Exec["fetch_notifications"],
      Exec["fetch_sitescripts"]
    ],
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
