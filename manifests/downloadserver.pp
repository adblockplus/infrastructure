node 'download1' {
  include base, statsclient

  class {'downloadserver':
    domain => 'downloads.adblockplus.org',
    is_default => true
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
