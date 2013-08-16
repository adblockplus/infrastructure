node 'server21' {
  include base, updateserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
