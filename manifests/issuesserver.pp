node 'issues1' {
  include base

  class {'trac':
    domain => 'issues.adblockplus.org',
    is_default => true,
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
