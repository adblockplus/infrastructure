node 'hg1' {
  class {'hg':
  	user => 'rhodecode',
  }

  #class {'nagios::client':
  #  server_address => 'hg.adblockplus.org'
  #}
}