node 'hgserver' {
  class {'rhodecode':
  	user => 'rhodecode',
  }

  #class {'nagios::client':
  #  server_address => 'hg.adblockplus.org'
  #}
}
