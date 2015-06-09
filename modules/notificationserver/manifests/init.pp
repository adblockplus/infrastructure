class notificationserver($is_default = false) {
  if !defined(Class['nginx']) {
    class {'nginx':
      worker_processes => 2,
      worker_connections => 4000,
      ssl_session_cache => off,
    }
  }

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/notificationserver/sitescripts.ini'
  }

  exec {'fetch_notifications':
    command => 'hg clone --noupdate https://hg.adblockplus.org/notifications /opt/notifications && chown -R nginx /opt/notifications',
    path => ['/usr/bin/', '/bin/'],
    require => [
      Package['mercurial'],
      Package['nginx'],
    ],
    onlyif => 'test ! -d /opt/notifications'
  }

  include spawn-fcgi
  package {'python-flup':}

  spawn-fcgi::pool {'multiplexer':
    ensure => present,
    fcgi_app => '/opt/sitescripts/multiplexer.fcgi',
    socket => '/tmp/multiplexer-fastcgi.sock',
    mode => '0666',
    user => 'nginx',
    children => 1,
    require => [
      Exec['fetch_sitescripts'],
      Exec['fetch_notifications'],
      Package['python-flup']
    ]
  }

  File {
    owner => root,
    group => root,
    mode => 0644,
  }

  nginx::hostconfig{'notification.adblockplus.org':
    source => 'puppet:///modules/notificationserver/site.conf',
    global_config => template('notificationserver/global.conf.erb'),
    is_default => $is_default,
    certificate => 'easylist-downloads.adblockplus.org_sslcert.pem',
    private_key => 'easylist-downloads.adblockplus.org_sslcert.key',
    log => 'access_log_notification',
    log_format => 'notification',
  }
}
