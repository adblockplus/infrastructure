class nginx (
    $service_subscribe = undef
  ){

  package {'nginx': ensure => 'present'}

  user {'nginx':
    ensure => present,
    uid => 106,
    gid => users,
    comment => 'User for nginx',
    home => '/var/lib/nginx',
    shell => '/bin/false',
    managehome => false
  }

  file {'/etc/nginx/nginx.conf':
    mode => 644,
    owner => root,
    group => root,
    source => 'puppet:///modules/nginx/nginx.conf',
    require => Package['nginx']
  }

  file {'/etc/logrotate.d/nginx':
    mode => 644,
    owner => root,
    group => root,
    source => 'puppet:///modules/nginx/logrotate',
    require => File['/etc/nginx/nginx.conf']
  }
  
  service {'nginx':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => [
                 File['/etc/nginx/nginx.conf'],
                 User['nginx']
               ],
    subscribe => $service_subscribe
  }  
}
