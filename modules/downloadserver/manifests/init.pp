class downloadserver(
    $domain,
    $is_default = false
  ) {

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

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/downloadserver/site.conf',
    is_default => $is_default,
    certificate => 'adblockplus.org_sslcert.pem',
    private_key => 'adblockplus.org_sslcert.key',
    log => 'access_log_downloads'
  }

  cron {'mirror':
    ensure => present,
    command => 'hg pull -q -u -R /var/www/downloads/',
    environment => ['MAILTO=admins@adblockplus.org,root'],
    user => hg,
    minute => '*/10'
  }

  file {'/var/www/devbuilds':
    ensure => directory,
    owner => rsync
  }

  user {'rsync':
    ensure => present,
    home => '/home/rsync',
    managehome => true
  }

  file {'/home/rsync/.ssh':
    ensure => directory,
    require => User['rsync'],
    owner => rsync,
    mode => 0600;
  }

  file {'/home/rsync/.ssh/known_hosts':
    ensure => file,
    owner => rsync,
    mode => 0444,
    source => 'puppet:///modules/downloadserver/known_hosts'
  }

  file {'/home/rsync/.ssh/id_rsa':
    ensure => file,
    owner => rsync,
    mode => 0400,
    source => 'puppet:///modules/private/rsync@downloads.adblockplus.org'
  }

  file {'/home/rsync/.ssh/id_rsa.pub':
    ensure => file,
    owner => rsync,
    mode => 0400,
    source => 'puppet:///modules/private/rsync@downloads.adblockplus.org.pub'
  }

  cron {'mirror-devbuilds':
    ensure => present,
    require => [File['/home/rsync/.ssh/known_hosts'],
                File['/home/rsync/.ssh/id_rsa'],
                File['/var/www/devbuilds']],
    command => 'rsync -e ssh -ltprz --delete devbuilds@ssh.adblockplus.org:. /var/www/devbuilds',
    environment => ['MAILTO=admins@adblockplus.org,root'],
    user => rsync,
    hour => '*',
    minute => '4-54/10'
  }
}
