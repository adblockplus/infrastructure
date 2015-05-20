node 'download1', 'download2', 'download3' {
  include statsclient

  class {'downloadserver':
    domain => 'downloads.adblockplus.org',
    certificate => 'downloads.adblockplus.org_sslcert.pem',
    private_key => 'downloads.adblockplus.org_sslcert.key',
    is_default => true
  }

}
