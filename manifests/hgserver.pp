node 'hgserver' {
  class {'rhodecode':
  	user => 'rhodecode',
  }

  class {'nagios::client':
    server_address => 'hg1.adblockplus.org'
  }
}
