class statsmaster(
    $domain,
    $is_default=false
  ) {
  user {'stats':
    ensure => present,
    home => '/home/stats',
    managehome => true,
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

  package {['pypy', 'python-jinja2']:}

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/statsmaster/sitescripts.ini',
  }

  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  File {
    owner => root,
    group => root,
  }

  file {'/var/www':
    ensure => directory,
    mode => 0755,
    require => Package['nginx'],
  }

  file {'/var/www/stats':
    ensure => directory,
    mode => 0755,
    owner => stats,
  }

  file {'/var/www/statsdata':
    ensure => directory,
    mode => 0755,
    owner => stats,
  }

  file {'/var/www/statsdata/usercounts.html':
    ensure => file,
    mode => 0444,
    source => 'puppet:///modules/statsmaster/usercounts.html',
    owner => stats,
  }

  file {'/var/www/htpasswd':
    ensure => file,
    mode => 0444,
    source => 'puppet:///modules/private/stats-htpasswd',
  }

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/statsmaster/site.conf',
    is_default => $is_default,
    certificate => 'adblockplus.org_sslcert.pem',
    private_key => 'adblockplus.org_sslcert.key',
    log => 'access_log_stats'
  }

  cron {'updatestats':
    ensure => present,
    require => [
                 Package['pypy'],
                 Package['python-jinja2'],
                 Exec["fetch_sitescripts"]
               ],
    command => "pypy -m sitescripts.stats.bin.logprocessor && python -m sitescripts.stats.bin.pagegenerator",
    environment => ['MAILTO=admins@adblockplus.org,root', 'PYTHONPATH=/opt/sitescripts'],
    user => stats,
    hour => 1,
    minute => 30,
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
