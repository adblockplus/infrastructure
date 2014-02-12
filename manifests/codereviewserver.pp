node 'codereview1' {
  include base
  class {'rietveld':
    domain => 'codereview.adblockplus.org'
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
