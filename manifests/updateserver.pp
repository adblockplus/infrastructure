node 'update1' {
  include base, statsclient

  class {'updateserver':
    domain => 'update.adblockplus.org',
    is_default => true
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
