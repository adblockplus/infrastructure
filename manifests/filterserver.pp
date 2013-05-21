node 'server1', 'server3', 'server5', 'server6', 'server7', 'server8', 'server9', 'server11', 'server12' {
  include base, filterserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
