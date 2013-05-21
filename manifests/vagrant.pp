define hostentry (
  $host = $title['host'],
  $ip = $title['ip']
) {
  host {$host:
    ensure => present,
    ip => $ip,
    name => $host
  }
}

node default {

  $hosts = [
    {host => 'localhost', ip => '127.0.0.1'},
    {host => $hostname, ip => '127.0.0.1'},
    {host => 'monitoring.adblockplus.org', ip => '10.8.0.98'},
    {host => 'intraforum.adblockplus.org', ip => '10.8.0.105'},
    {host => 'server_1.adblockplus.org', ip => '10.8.0.105'},
    {host => 'server_3.adblockplus.org', ip => '10.8.0.99'},
    {host => 'server_4.adblockplus.org', ip => '10.8.0.98'},
    {host => 'server_5.adblockplus.org', ip => '10.8.0.100'},
    {host => 'server_6.adblockplus.org', ip => '10.8.0.101'},
    {host => 'server_7.adblockplus.org', ip => '10.8.0.102'},
    {host => 'server_8.adblockplus.org', ip => '10.8.0.103'},
    {host => 'server_9.adblockplus.org', ip => '10.8.0.104'},
    {host => 'server_10.adblockplus.org', ip => '10.8.0.105'}
    {host => 'server_11.adblockplus.org', ip => '10.8.0.106'}
    {host => 'server_12.adblockplus.org', ip => '10.8.0.107'}
  ]

  hostentry { $hosts: }
}
