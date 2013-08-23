class statsclient (
    $log_path,
    $custom_sitescriptsini_source = [],
  ) {

  $sitescriptsini_source = flatten(['puppet:///modules/statsclient/sitescripts.ini', $custom_sitescriptsini_source])

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

  file {'/home/stats/.ssh/authorized_keys':
    ensure => present,
    owner => stats,
    mode => 0400,
    source => 'puppet:///modules/private/stats-authorized_keys',
  }

  class {'ssh':
    custom_configuration => 'Match User stats
        AllowTcpForwarding no
        X11Forwarding no
        AllowAgentForwarding no
        GatewayPorts no
        ForceCommand cat /var/www/stats.json',
  }

  class {'sitescripts':
    sitescriptsini_source => $sitescriptsini_source,
  }

  package {'python-geoip':}

  package {'python-simplejson':}

  file {'/var/www/stats.json':
    ensure => present,
    owner => stats,
    mode => 644,
  }

  file {'/opt/cron_geoipdb_update.sh':
    ensure => file,
    owner => root,
    mode => 0750,
    source => 'puppet:///modules/statsclient/cron_geoipdb_update.sh',
  }

  cron {'mirrorstats':
    ensure => present,
    require => [
                 User['stats'],
                 Package['python-geoip'],
                 Exec["fetch_sitescripts"]
               ],
    command => "gzip -cd ${log_path} | python -m sitescripts.stats.bin.logprocessor",
    environment => ['MAILTO=admins@adblockplus.org', 'PYTHONPATH=/opt/sitescripts'],
    user => stats,
    hour => 0,
    minute => 25,
  }

  cron {'geoipdb_update':
    ensure => present,
    require => File['/opt/cron_geoipdb_update.sh'],
    command => '/opt/cron_geoipdb_update.sh',
    user => root,
    hour => 3,
    minute => 15,
    monthday => 3,
  }
}
