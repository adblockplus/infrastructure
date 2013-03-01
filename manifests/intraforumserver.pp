node 'server10' {
  include base, ssh, discourse

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
