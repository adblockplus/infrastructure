node 'server3', 'server5', 'server6', 'server7', 'server8', 'server9' {
  include base, filterserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
