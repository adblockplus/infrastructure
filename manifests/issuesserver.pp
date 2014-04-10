node 'issues1' {
  include base

  class {'trac':
    domain => 'issues.adblockplus.org',
    certificate => 'issues.adblockplus.org_sslcert.pem',
    private_key => 'issues.adblockplus.org_sslcert.key',
    is_default => true,
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
