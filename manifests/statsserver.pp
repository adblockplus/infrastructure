node 'server22', 'stats1' {
  include base, statsmaster

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
