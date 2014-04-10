node 'server10' {
  include base, ssh

  class {'discourse':
    domain => 'intraforum.adblockplus.org',
    certificate => 'intraforum.adblockplus.org_sslcert.pem',
    private_key => 'intraforum.adblockplus.org_sslcert.key',
    is_default => true,
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
