node 'filtermaster1' {
  include base, filtermaster

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
