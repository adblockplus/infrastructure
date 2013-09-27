node 'server13', 'download1' {
  include base, downloadserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
