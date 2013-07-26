class filterserver {
  user {'subscriptionstat':
    ensure => present,
    home => '/home/subscriptionstat',
    managehome => true
  }

  file {'/home/subscriptionstat/.ssh':
    ensure => directory,
    owner => subscriptionstat,
    mode => 0600,
    require => User['subscriptionstat']
  }

  file {'/home/subscriptionstat/.ssh/authorized_keys':
    ensure => present,
    owner => subscriptionstat,
    mode => 0400,
    source => 'puppet:///modules/private/subscriptionstat-authorized_keys'
  }

  class {'ssh':
    custom_configuration => 'Match User subscriptionstat
        AllowTcpForwarding no
        X11Forwarding no
        AllowAgentForwarding no
        GatewayPorts no
        ForceCommand cat /var/www/subscriptionStats.ini'
  }

  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/filterserver/sitescripts.ini'
  }

  package {'python-geoip':}

  user {'rsync':
    ensure => present,
    comment => 'Filter list mirror user',
    home => '/home/rsync',
    managehome => true
  }

  File {
    owner => root,
    group => root,
    mode => 0644,
  }

  file {'/var/www':
    ensure => directory
  }

  file {'/var/www/easylist':
    ensure => directory,
    require => [
                 File['/var/www'],
                 User['rsync']
               ],
    owner => rsync
  }

  file {'/var/www/subscriptionStats.ini':
    ensure => present,
    owner => rsync
  }

  file {'/etc/nginx/sites-available/inc.easylist-downloads':
    ensure => absent,
  }

  file {'/etc/nginx/sites-available/inc.easylist-downloads-txt':
    ensure => absent
  }

  file {'/etc/nginx/sites-available/inc.easylist-downloads-tpl':
    ensure => absent
  }

  file {'/etc/nginx/sites-available/easylist-downloads.adblockplus.org_sslcert.key':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['easylist-downloads.adblockplus.org'],
    source => 'puppet:///modules/private/easylist-downloads.adblockplus.org_sslcert.key'
  }

  file {'/etc/nginx/sites-available/easylist-downloads.adblockplus.org_sslcert.pem':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['easylist-downloads.adblockplus.org'],
    mode => 0400,
    source => 'puppet:///modules/private/easylist-downloads.adblockplus.org_sslcert.pem'
  }

  nginx::hostconfig{'easylist-downloads.adblockplus.org':
    source => 'puppet:///modules/filterserver/easylist-downloads.adblockplus.org',
    enabled => true
  }

  file {'/etc/logrotate.d/nginx_easylist-downloads.adblockplus.org':
    ensure => file,
    require => Nginx::Hostconfig['easylist-downloads.adblockplus.org'],
    source => 'puppet:///modules/filterserver/logrotate'
  }

  file {'/home/rsync/.ssh':
    ensure => directory,
    require => User['rsync'],
    owner => rsync,
    mode => 0600;
  }

  file {'/home/rsync/.ssh/known_hosts':
    ensure => file,
    require => [
                 File['/home/rsync/.ssh'],
                 User['rsync']
               ],
    owner => rsync,
    mode => 0444,
    source => 'puppet:///modules/filterserver/known_hosts'
  }

  file {'/home/rsync/.ssh/id_rsa':
    ensure => file,
    require => [
                 File['/home/rsync/.ssh'],
                 User['rsync']
               ],
    owner => rsync,
    mode => 0400,
    source => 'puppet:///modules/private/rsync@easylist-downloads.adblockplus.org'
  }

  file {'/home/rsync/.ssh/id_rsa.pub':
    ensure => file,
    require => [
                 File['/home/rsync/.ssh'],
                 User['rsync']
               ],
    owner => rsync,
    mode => 0400,
    source => 'puppet:///modules/private/rsync@easylist-downloads.adblockplus.org.pub'
  }

  file {'/opt/cron_geoipdb_update.sh':
    ensure => file,
    mode => 0750,
    source => 'puppet:///modules/filterserver/cron_geoipdb_update.sh'
  }

  cron {'mirror':
    ensure => present,
    require => [
                 File['/home/rsync/.ssh/known_hosts'],
                 File['/home/rsync/.ssh/id_rsa'],
                 User['rsync']
               ],
    command => 'rsync -e ssh -ltprz rsync@ssh.adblockplus.org:. /var/www/easylist/',
    user => rsync,
    hour => '*',
    minute => '2-52/10'
  }

  cron {'mirrorstats':
    ensure => present,
    require => [
                 User['rsync'],
                 Package['python-geoip'],
                 Exec["fetch_sitescripts"]
               ],
    command => 'gzip -cd /var/log/nginx/access_log_easylist_downloads.1.gz | python -m sitescripts.logs.bin.extractSubscriptionStats',
    environment => ['MAILTO=admins@adblockplus.org', 'PYTHONPATH=/opt/sitescripts'],
    user => rsync,
    hour => 1,
    minute => 25
  }

  cron {'geoipdb_update':
    ensure => present,
    require => File['/opt/cron_geoipdb_update.sh'],
    command => '/opt/cron_geoipdb_update.sh',
    user => root,
    hour => 3,
    minute => 15,
    monthday => 3
  }

}
