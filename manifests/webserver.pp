node 'server0' {
  include base, adblockplusorg

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
