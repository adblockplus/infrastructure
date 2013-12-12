node 'web1' {
  include base

  class {'web::server':
    vhost => 'eyeo.com',
    repository => 'web.eyeo.com',
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
