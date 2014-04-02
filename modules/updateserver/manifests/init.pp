class updateserver(
    $domain,
    $is_default=false
  ) {
  class {'nginx':
    worker_processes => 2,
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  File {
    owner => root,
    group => root
  }

  file {'/var/www':
    ensure => directory,
    mode => 0755,
    require => Package['nginx']
  }

  file {'/var/www/update':
    ensure => directory,
    mode => 0755
  }

  file {'/var/www/update/adblockplusie':
    ensure => directory,
    mode => 0755
  }

  file {'/var/www/update/adblockplusie/update.json':
    ensure => file,
    source => 'puppet:///modules/updateserver/adblockplusie/update.json',
    mode => 0644
  }

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/updateserver/site.conf',
    is_default => $is_default,
    certificate => 'adblockplus.org_sslcert.pem',
    private_key => 'adblockplus.org_sslcert.key',
    log => 'access_log_update'
  }
}
