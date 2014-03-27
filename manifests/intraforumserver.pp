node 'server10' {
  include base, ssh

  class {'discourse':
    domain => 'intraforum.adblockplus.org',
    is_default => true,
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
