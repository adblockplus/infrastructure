class nginx (
    $worker_processes = $nginx::params::worker_processes,
    $worker_connections = $nginx::params::worker_connections,
    $ssl_session_cache =  $nginx::params::ssl_session_cache
  ) inherits nginx::params {

  include apt

  apt::source {'nginx':
    location => "http://nginx.org/packages/ubuntu",
    repos => "nginx",
    key => "ABF5BD827BD9BF62",
    key_source => "http://nginx.org/keys/nginx_signing.key"
  }

  # Ensures that nginx is not installed from the Ubuntu sources
  package {'nginx-common':
    ensure => purged,
    before => Package['nginx']
  }

  package {'nginx':
    ensure => '1.6.0-1~precise',
    require => Apt::Source['nginx']
  }

  File {
    owner => root,
    group => root,
    mode => 0644,
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

  service {'nginx':
    ensure => running,
    enable => true,
    restart => '/etc/init.d/nginx reload',
    hasstatus => true,
    require => File['/etc/nginx/nginx.conf']
  }
}
