node default {
  class {'hosts':
    hosts => {
      'localhost' => '127.0.0.1',
      "${hostname}" => '127.0.0.1',
      'www.adblockplus.org' => '10.8.0.97',
      'monitoring.adblockplus.org' => '10.8.0.98',
      'server_3.adblockplus.org' => '10.8.0.99'
    }
  }
}
