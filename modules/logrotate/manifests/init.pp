class logrotate {

  include private::global

  exec {'ensure_logrotate_status':
    command => '/etc/cron.daily/logrotate',
    path => ["/usr/bin/", "/bin/"],
    onlyif => 'test ! -f /var/lib/logrotate/status'
  }

  cron {'logrotate':
    ensure => present,
    require => Exec['ensure_logrotate_status'],
    command => '/usr/sbin/logrotate /etc/logrotate.conf',
    environment => ["MAILTO=$private::global::admin,root"],
    user => root,
    hour => '0',
    minute => '0'
  }
}
