class filterserver($is_default = false) {
  if !defined(Class['nginx']) {
    class {'nginx':
      worker_connections => 4000,
      ssl_session_cache => off,
    }
  }

  if !defined(File['/var/www']) {
    file {'/var/www':
      ensure => directory,
      owner => nginx,
      mode => 0755,
      require => Package['nginx']
    }
  }

  user {'subscriptionstat':
    ensure => absent,
  }

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

  file {'/var/www/easylist':
    ensure => directory,
    owner => rsync
  }

  nginx::hostconfig{'easylist-downloads.adblockplus.org':
    alt_names => 'easylist-msie.adblockplus.org',
    source => 'puppet:///modules/filterserver/site.conf',
    is_default => $is_default,
    certificate => 'easylist-downloads.adblockplus.org_sslcert.pem',
    private_key => 'easylist-downloads.adblockplus.org_sslcert.key',
    log => 'access_log_easylist_downloads'
  }

  file {'/home/rsync/.ssh':
    ensure => directory,
    require => User['rsync'],
    owner => rsync,
    mode => 0600;
  }

  concat {'/home/rsync/.ssh/known_hosts':
    owner => rsync,
    mode => 0444,
  }

  concat::fragment {'filtermaster_hostname':
    target => '/home/rsync/.ssh/known_hosts',
    content => 'filtermaster.adblockplus.org ',
    order => 1,
  }

  concat::fragment {'filtermaster_hostkey':
    target => '/home/rsync/.ssh/known_hosts',
    source => 'puppet:///modules/private/filtermaster.adblockplus.org_ssh.pub',
    order => 2,
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

  cron {'mirror':
    ensure => present,
    require => [
                 File['/home/rsync/.ssh/known_hosts'],
                 File['/home/rsync/.ssh/id_rsa'],
                 User['rsync']
               ],
    command => 'rsync -e "ssh -o CheckHostIP=no" -ltprz --delete rsync@filtermaster.adblockplus.org:. /var/www/easylist/',
    environment => ['MAILTO=admins@adblockplus.org,root'],
    user => rsync,
    hour => '*',
    minute => '2-52/10'
  }
}
