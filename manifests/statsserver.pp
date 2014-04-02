node 'stats1' {
  include base

  class {'statsmaster':
    domain => 'stats.adblockplus.org',
    is_default => true
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
