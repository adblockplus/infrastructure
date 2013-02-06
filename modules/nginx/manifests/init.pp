class nginx (
    $worker_processes = $nginx::params::worker_processes,
    $worker_connections = $nginx::params::worker_connections
  ) inherits nginx::params {

  package {'nginx':
    ensure => present
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

#  file {'/etc/logrotate.d/nginx':
#    source => 'nginx/logrotate',
#    require => File['/etc/nginx/nginx.conf']
#  }

  service {'nginx':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => File['/etc/nginx/nginx.conf']
  }
}
