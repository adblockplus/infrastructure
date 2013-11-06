node 'server5', 'server6', 'server7', 'server11', 'server12', 'server15', 'server19', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6' {
  include base, filterserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
