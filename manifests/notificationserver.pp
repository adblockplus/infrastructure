node 'server17', 'server18', 'notification1', 'notification2' {
  include base, notificationserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
