node 'download1' {
  include base, statsclient

  class {'downloadserver':
    domain => 'downloads.adblockplus.org',
    certificate => 'downloads.adblockplus.org_sslcert.pem',
    private_key => 'downloads.adblockplus.org_sslcert.key',
    is_default => true
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
