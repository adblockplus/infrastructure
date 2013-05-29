node 'server1', 'server3', 'server5', 'server6', 'server7', 'server8', 'server9', 'server11', 'server12', 'server14', 'server15' {
  include base, filterserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
