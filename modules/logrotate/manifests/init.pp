class logrotate {
  exec {'ensure_logrotate_status':
    command => '/etc/cron.daily/logrotate',
    path => ["/usr/bin/", "/bin/"],
    onlyif => 'test ! -f /var/lib/logrotate/status'
  }

  cron {'logrotate':
    ensure => 'absent',
  }

  $config = hiera('logrotate::config', {})
  create_resources('logrotate::config', $config)
}
