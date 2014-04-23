class statsmaster(
    $domain,
    $certificate,
    $private_key,
    $is_default=false
  ) {

  include statsmaster::downloads, statsmaster::awstats

  user {'stats':
    ensure => present,
    home => '/home/stats',
    managehome => true,
  }

  File {
    group => root,
  }

  file {'/home/stats/.ssh':
    ensure => directory,
    owner => stats,
    mode => 0600,
    require => User['stats'],
  }

  file {'/home/stats/.ssh/id_rsa':
    ensure => present,
    owner => stats,
    mode => 0400,
    source => 'puppet:///modules/private/stats@stats.adblockplus.org',
  }

  file {'/home/stats/.ssh/known_hosts':
    ensure => present,
    owner => stats,
    mode => 0400,
    source => 'puppet:///modules/statsmaster/known_hosts',
  }

  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  file {'/var/www':
    ensure => directory,
    mode => 0755,
    owner => root
  }

  file {'/var/www/htpasswd':
    ensure => file,
    mode => 0444,
    source => 'puppet:///modules/private/stats-htpasswd',
    owner => root,
  }

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/statsmaster/site.conf',
    is_default => $is_default,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_stats'
  }

  file {'/opt/cron_geoipdb_update.sh':
    ensure => file,
    owner => root,
    mode => 0750,
    source => 'puppet:///modules/statsmaster/cron_geoipdb_update.sh',
  }

  cron {'geoipdb_update':
    ensure => present,
    require => File['/opt/cron_geoipdb_update.sh'],
    command => '/opt/cron_geoipdb_update.sh',
    environment => ['MAILTO=admins@adblockplus.org,root'],
    user => root,
    hour => 3,
    minute => 15,
    monthday => 3,
  }
}
