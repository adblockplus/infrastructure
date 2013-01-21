node default {
  class {'hosts':
    hosts => {
      'localhost' => '127.0.0.1',
      'precise64' => '127.0.0.1',
      'www.adblockplus.org' => '10.8.0.97',
      'monitoring.adblockplus.org' => '10.8.0.98',
    }
  }
}
