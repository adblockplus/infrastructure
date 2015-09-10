class nginx (
    $worker_processes = $nginx::params::worker_processes,
    $worker_connections = $nginx::params::worker_connections,
    $ssl_session_cache =  $nginx::params::ssl_session_cache
  ) inherits nginx::params {

  apt::ppa {'ppa:nginx/stable':
  }

  apt::source {'nginx':
    ensure => 'absent',
  }

  exec {'purge-nginx':
    command => '/usr/bin/apt-get -y purge nginx',
    logoutput => true,
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
    refreshonly => true,
    returns => [0, 100],
    subscribe => Apt::Ppa['ppa:nginx/stable'],
  }

  package {'nginx':
    ensure => '1.8.0-1+precise1',
    require => Exec['purge-nginx'],
  }

  File {
    owner => root,
    group => root,
    mode => 0644,
  }

  Exec {
    path => '/usr/bin:/bin',
    logoutput => 'on_failure',
  }


  file {'/etc/nginx/nginx.conf':
    content => template('nginx/nginx.conf.erb'),
    require => Package['nginx'],
    notify => Service['nginx']
  }

  file {'/etc/nginx/sites-available':
    ensure => directory,
    require => Package['nginx']
  }

  file {'/etc/nginx/sites-enabled':
    ensure => directory,
    require => Package['nginx']
  }

  define hostconfig (
      $domain = $title,
      $alt_names = [],
      $log,
      $log_format = 'main',
      $is_default = false,
      $source = undef,
      $content = undef,
      $global_config = undef,
      $certificate = undef,
      $private_key = undef,
      $enabled = true) {
    file {"/etc/nginx/sites-available/${domain}":
      ensure  => file,
      content => template('nginx/site.erb'),
      require => Package['nginx'],
      notify => Service['nginx'],
    }

    if $certificate and $private_key {
      if !defined(File["/etc/nginx/${certificate}"]) {
        file {"/etc/nginx/${certificate}":
          ensure => file,
          mode => 0400,
          notify => Service['nginx'],
          before => File["/etc/nginx/sites-available/${domain}"],
          require => Package['nginx'],
          source => "puppet:///modules/private/${certificate}"
        }
      }

      if !defined(File["/etc/nginx/${private_key}"]) {
        file {"/etc/nginx/${private_key}":
          ensure => file,
          mode => 0400,
          notify => Service['nginx'],
          before => File["/etc/nginx/sites-available/${domain}"],
          require => Package['nginx'],
          source => "puppet:///modules/private/${private_key}"
        }
      }

      if !defined(File["/etc/nginx/sites-available/${certificate}"]) {
        file {"/etc/nginx/sites-available/${certificate}":
          ensure => absent
        }
      }

      if !defined(File["/etc/nginx/sites-available/${private_key}"]) {
        file {"/etc/nginx/sites-available/${private_key}":
          ensure => absent
        }
      }
    }

    if $enabled == true {

      if $is_default {
        $default_conf = '/etc/nginx/sites-enabled/default'
        ensure_resource('file', $default_conf, {ensure => 'absent'})
        Package['nginx'] -> File[$default_conf] ~> Service['nginx']
      }

      file {"/etc/nginx/sites-enabled/${domain}":
        ensure  => link,
        require => File["/etc/nginx/sites-available/${domain}"],
        target => "/etc/nginx/sites-available/${domain}",
        notify => Service['nginx']
      }
    }

    file {"/etc/logrotate.d/nginx_$domain":
      ensure => file,
      require => File["/etc/nginx/sites-available/${domain}"],
      content => template('nginx/logrotate.erb')
    }
  }

  file {'/etc/logrotate.d/nginx':
    source => 'puppet:///modules/nginx/logrotate',
    require => Package['nginx']
  }

  $find_cmd_base = [
    'find', '/var/log/nginx',
    '-mindepth', '1', '-maxdepth', '1', '-type', 'f',
  ]

  # Kill the find process to force an exit status != 0 by finding the parent pid
  # of the exec's sh process
  $find_kill_exec = [
    '-exec', 'sh', '-c',
    'ps -p $$ -o ppid= | xargs kill -TERM',
     ';',
  ]

  $find_chown_base = [
    $find_cmd_base,
    '-not', '(', '-user', $nginx::params::user, '-and', '-group', 'adm', ')',
  ]
  $find_chown_exec = [
    '-ls', '-exec', 'chown',
    "${nginx::params::user}.adm", '{}', ';',
  ]

  exec {"set_logfiles_owner":
    command => shellquote($find_chown_base, $find_chown_exec),
    unless => shellquote($find_chown_base, $find_kill_exec),
    subscribe => Service['nginx'], 
  }

  $find_chmod_base = [$find_cmd_base, '-not', '-perm', '0640']
  $find_chmod_exec = ['-ls', '-exec', 'chmod', '0640', '{}', ';']

  exec {"set_logfiles_permissions":
    command => shellquote($find_chmod_base, $find_chmod_exec),
    unless => shellquote($find_chmod_base, $find_kill_exec),
    subscribe => Service['nginx'],
  }

  service {'nginx':
    ensure => running,
    enable => true,
    restart => '/etc/init.d/nginx reload',
    hasstatus => true,
    require => File['/etc/nginx/nginx.conf']
  }
}
