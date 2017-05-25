class notificationserver($is_default = false) {
  if !defined(Class['nginx']) {
    class {'nginx':
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
      User['nginx'],
    ],
    onlyif => 'test ! -d /opt/notifications'
  }

  cron {'update_notifications':
    command => 'hg pull -q -u -R /opt/notifications',
    environment => hiera('cron::environment', []),
    minute => '2-59/20',
    user => 'nginx',
    require => Exec['fetch_notifications'],
  }

  include spawn_fcgi

  spawn_fcgi::pool {'multiplexer':
    ensure => present,
    fcgi_app => '/opt/sitescripts/multiplexer.fcgi',
    socket => '/tmp/multiplexer-fastcgi.sock',
    mode => '0666',
    order => 500,
    user => 'nginx',
    children => 1,
    require => [
      Class['sitescripts'],
      Exec['fetch_notifications'],
    ]
  }

  customservice::supervisor {'spawn-fcgi':
    pidfile => '/var/run/500-multiplexer_spawn-fcgi.pid',
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
