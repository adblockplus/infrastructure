class nginx (
    $service_subscribe = undef
  ){

  package {'nginx': ensure => 'present'}

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
    require => File['/etc/nginx/nginx.conf'],
    subscribe => $service_subscribe
  }  
}
