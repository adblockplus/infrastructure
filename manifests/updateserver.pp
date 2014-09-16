node 'update1' {
  include base, statsclient

  class {'updateserver':
    domain => 'update.adblockplus.org',
    certificate => 'update.adblockplus.org_sslcert.pem',
    private_key => 'update.adblockplus.org_sslcert.key',
    is_default => true
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
