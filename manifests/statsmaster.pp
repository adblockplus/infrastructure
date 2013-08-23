node 'server22' {
  include base, statsmaster

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
