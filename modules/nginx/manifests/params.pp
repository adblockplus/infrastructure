class nginx::params {
  $worker_processes = hiera('nginx::worker_processes', $::processorcount)
  $worker_connections = hiera('nginx::worker_connections', 1024)
  $multi_accept = off
  $worker_rlimit_nofile = 30000
  $sendfile = on
  $keepalive_timeout = 15
  $tcp_nodelay = on
  $gzip = on
  $ssl_session_cache = on

  $user = $::operatingsystem ? {
    /(?i-mx:debian|ubuntu)/ => 'www-data',
    /(?i-mx:fedora|rhel|redhat|centos|scientific|suse|opensuse)/ => 'nginx',
  }

  $group = $::operatingsystem ? {
    /(?i-mx:debian|ubuntu)/ => 'www-data',
    /(?i-mx:fedora|rhel|redhat|centos|scientific|suse|opensuse)/ => 'www',
  }
}
