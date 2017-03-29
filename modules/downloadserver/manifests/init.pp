class downloadserver(
    $domain,
    $certificate,
    $private_key,
    $is_default = false
  ) {

  class {'nginx':
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/downloadserver/sitescripts',
  }

  package {'python-jinja2':}
  include spawn-fcgi

  spawn-fcgi::pool {'multiplexer':
    ensure => present,
    fcgi_app => '/opt/sitescripts/multiplexer.fcgi',
    socket => '/tmp/multiplexer-fastcgi.sock',
    mode => '0666',
    user => 'nginx',
    children => 1,
    require => [
      Class['sitescripts'],
      Package['python-jinja2'],
    ],
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
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_downloads'
  }

  file {'/etc/nginx/conf.d/adblockbrowserupdatescache.conf':
    source => 'puppet:///modules/downloadserver/adblockbrowserupdatescache.conf',
    require => Package['nginx'],
    notify => Service['nginx']
  }

  cron {'mirror':
    ensure => present,
    command => 'hg pull -q -u -R /var/www/downloads/',
    environment => hiera('cron::environment', []),
    user => hg,
    minute => '3-59/20'
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
    require => [File['/home/rsync/.ssh/id_rsa'],
                File['/var/www/devbuilds']],
    command => 'rsync -e ssh -ltprz --delete devbuilds@server16.adblockplus.org:. /var/www/devbuilds',
    environment => hiera('cron::environment', []),
    user => rsync,
    hour => '*',
    minute => '4-54/10'
  }
}
