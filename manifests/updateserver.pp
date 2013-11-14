node 'server21', 'update1' {
  include base, updateserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
