node 'update1' {
  include base, statsclient, updateserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
