class base ($zone='adblockplus.org') {
  stage {'pre': before => Stage['main']}
  stage {'post': require => Stage['main']}

  class {'users':
    stage => 'pre',
  }

  class {'apt':
    always_apt_update => true
  }

  Exec['apt_update'] -> Package <| |>

  include private::users, postfix, ssh

  package {['mercurial', 'vim', 'emacs', 'debian-goodies', 'htop']:
    ensure => present,
  }

  file {'/etc/timezone':
    ensure => file,
    owner => root,
    group => root,
    mode => 0644,
    content => 'UTC',
    notify => Service['cron']
  }

  file {'/etc/localtime':
    ensure => link,
    target => '/usr/share/zoneinfo/UTC',
    notify => Service['cron']
  }

  service {'cron':
    ensure => running,
    enable => true,
  }

  class {'logrotate':
    stage => 'post'
  }

  $servers = hiera('servers')
  create_resources(base::explicit_host_record, $servers)

  define explicit_host_record(
    $ip,
    $ssh_public_key = undef,
    $role           = undef,
    $dns            = undef,
    $groups         = undef,
  ) {
    
    if is_array($ip) {
      $internal_ip = $ip[0]
    } else {
      $internal_ip = $ip
    }

    $fqdn_name = join([$name, $base::zone], '.')
    
    host{$name:
      ensure => present,
      ip => $internal_ip,
      name => $fqdn_name,
      host_aliases => $dns ? {
        undef => [],
        default => $dns,
      }  
    }

    if $ssh_public_key != undef {

      $name_key = $dns ? {
        undef => $fqdn_name,
        default => $dns,
      }

      @sshkey {$name:
        name => $name_key,
        key => $ssh_public_key,
        type => ssh-rsa,
        host_aliases => $ip,
      }
    }

  }
}

