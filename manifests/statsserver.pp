node 'stats1' {
  include base

  class {'statsmaster':
    domain => 'stats.adblockplus.org',
    certificate => 'stats.adblockplus.org_sslcert.pem',
    private_key => 'stats.adblockplus.org_sslcert.key',
    is_default => true
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
