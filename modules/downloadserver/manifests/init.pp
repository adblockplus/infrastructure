class downloadserver {
  user {'stats':
    ensure => present,
    home => '/home/stats',
    managehome => true
  }

  file {'/home/stats/.ssh':
    ensure => directory,
    owner => stats,
    mode => 0600,
    require => User['stats']
  }

  file {'/home/stats/.ssh/authorized_keys':
    ensure => present,
    owner => stats,
    mode => 0400,
    source => 'puppet:///modules/private/subscriptionstat-authorized_keys'
  }

  class {'ssh':
    custom_configuration => 'Match User stats
        AllowTcpForwarding no
        X11Forwarding no
        AllowAgentForwarding no
        GatewayPorts no
        ForceCommand cat /var/www/stats.ini'
  }

  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  user {'hg':
    ensure => present,
    comment => 'Mercurial client user',
    home => '/home/hg',
    managehome => true
  }

  file {'/var/www':
    ensure => directory,
    owner => hg,
    mode => 0644
  }

  exec { "fetch_downloads":
    command => "hg clone https://hg.adblockplus.org/downloads /var/www/downloads",
    path => ["/usr/bin/", "/bin/"],
    require => Package['mercurial'],
    user => hg,
    timeout => 0,
    onlyif => "test ! -d /var/www/downloads"
  }

  File {
    owner => root,
    group => root,
    mode => 0644,
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.key':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['downloads.adblockplus.org'],
    mode => 0400,
    source => 'puppet:///modules/private/adblockplus.org_sslcert.key'
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.pem':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['downloads.adblockplus.org'],
    mode => 0400,
    source => 'puppet:///modules/private/adblockplus.org_sslcert.pem'
  }

  nginx::hostconfig{'downloads.adblockplus.org':
    source => 'puppet:///modules/downloadserver/downloads.adblockplus.org',
    enabled => true
  }

  file {'/etc/logrotate.d/nginx_downloads.adblockplus.org':
    ensure => file,
    mode => 0444,
    require => Nginx::Hostconfig['downloads.adblockplus.org'],
    source => 'puppet:///modules/downloadserver/logrotate'
  }

  cron {'mirror':
    ensure => present,
    command => 'hg pull -q -u -R /var/www/downloads/',
    user => hg,
    minute => '*/10'
  }
}