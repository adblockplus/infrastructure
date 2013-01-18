node default {
  include base, adblockplusorg

  class {'nagios::client':
    server_ip => '10.8.0.98'
  }
}
