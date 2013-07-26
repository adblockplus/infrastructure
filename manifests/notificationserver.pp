node 'server17', 'server18' {
  include base, notificationserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
