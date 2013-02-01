node default {
  class {'hosts':
    hosts => {
      'localhost' => '127.0.0.1',
      "${hostname}" => '127.0.0.1',
      'www.adblockplus.org' => '10.8.0.97',
      'monitoring.adblockplus.org' => '10.8.0.98',
      'server_1.adblockplus.org' => '10.8.0.105',
      'server_3.adblockplus.org' => '10.8.0.99',
      'server_4.adblockplus.org' => '10.8.0.98',
      'server_5.adblockplus.org' => '10.8.0.100',
      'server_6.adblockplus.org' => '10.8.0.101',
      'server_7.adblockplus.org' => '10.8.0.102',
      'server_8.adblockplus.org' => '10.8.0.103',
      'server_9.adblockplus.org' => '10.8.0.104'
    }
  }
}
