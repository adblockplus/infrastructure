node 'server17' {
  include base, notificationserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
