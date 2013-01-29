node 'server0' {
  include base, ssh, adblockplusorg

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
