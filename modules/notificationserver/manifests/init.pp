class notificationserver($is_default = false) {
  if !defined(Class['nginx']) {
    class {'nginx':
      worker_processes => 2,
      worker_connections => 4000,
      ssl_session_cache => off,
    }
  }

  if !defined(File['/var/www']) {
    file {'/var/www':
      ensure => directory,
      owner => nginx,
      mode => 0755,
      require => Package['nginx']
    }
  }

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/notificationserver/sitescripts.ini'
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
    require => [
      Package['mercurial'],
      Package['nginx'],
    ],
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

  nginx::hostconfig{'notification.adblockplus.org':
    source => 'puppet:///modules/notificationserver/site.conf',
    is_default => $is_default,
    certificate => 'adblockplus.org_sslcert.pem',
    private_key => 'adblockplus.org_sslcert.key',
    log => 'access_log_notification'
  }
}
