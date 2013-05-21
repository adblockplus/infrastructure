node 'server13' {
  include base, downloadserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
