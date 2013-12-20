node 'notification1', 'notification2' {
  include base, notificationserver

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }

  class {'statsclient': }
}
