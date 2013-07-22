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
    ensure => '1.4.2-1~precise',
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

  file {'/etc/nginx/sites-available/default':
    ensure => absent,
    require => Package['nginx']
  }

#  file {'/etc/nginx/sites-enabled/default':
#    ensure => absent,
#  }

  define hostconfig ($file = $title, $source, $enabled = false) {
    file {"/etc/nginx/sites-available/${file}":
      ensure  => file,
      source => $source,
      require => Package['nginx'],
      notify => Service['nginx'],
    }
    if $enabled == true {
      file {"/etc/nginx/sites-enabled/${file}":
        ensure  => link,
        require => File["/etc/nginx/sites-available/${file}"],
        target => "/etc/nginx/sites-available/${file}",
        notify => Service['nginx']
      }
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
