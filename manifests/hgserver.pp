node 'hgserver' {
  class {'rhodecode':
    user => 'rhodecode',
    domain => 'hgserver.adblockplus.org',
    is_default => true,
  }

  class {'nagios::client':
    server_address => 'hgserver.adblockplus.org'
  }
}
