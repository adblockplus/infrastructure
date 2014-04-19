node 'codereview1' {
  include base
  class {'rietveld':
    domain => 'codereview.adblockplus.org',
    certificate => 'codereview.adblockplus.org_sslcert.pem',
    private_key => 'codereview.adblockplus.org_sslcert.key',
    is_default => true
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
