class notificationserver($is_default = false) {

  include nginx

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

  # http://hub.eyeo.com/issues/3927
  $cache_flush = 'find /var/cache/nginx/notification -type f -exec rm -rf {} +'
  $cache_user = 'www-data'

  # https://linux.die.net/man/5/sudoers
  file {'/etc/sudoers.d/notification-cache':
    content => "nginx ALL=($cache_user) NOPASSWD:/usr/bin/$cache_flush\n",
    ensure => 'present',
    group => 'root',
    mode => '0440',
    owner => 'root',
  }

  # https://docs.puppet.com/puppet/latest/types/augeas.html
  augeas {'files/opt/notifications/.hg/hgrc/hooks/cache':
    changes => [
      "set hooks/changegroup.cache 'sudo -u $cache_user $cache_flush'",
    ],
    incl => '/opt/notifications/.hg/hgrc',
    lens => 'Puppet.lns',
    require => [
      Exec['fetch_notifications'],
      File['/etc/sudoers.d/notification-cache'],
    ],
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
    mode => '0644',
  }

  nginx::hostconfig{'notification.adblockplus.org':
    source => 'puppet:///modules/notificationserver/site.conf',
    global_config => template('notificationserver/global.conf.erb'),
    is_default => $is_default,
    certificate => 'easylist-downloads.adblockplus.org_sslcert.pem',
    private_key => 'easylist-downloads.adblockplus.org_sslcert.key',
    log => 'access_log_notification',
    log_format => 'main',
  }
}
