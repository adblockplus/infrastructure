node 'server3', 'server5', 'server6', 'server7' {
  include base, filterserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
