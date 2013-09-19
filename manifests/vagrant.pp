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
    {host => 'monitoring.adblockplus.org', ip => '10.8.0.99'},
    {host => 'intraforum.adblockplus.org', ip => '10.8.0.105'},
    {host => 'downloads.adblockplus.org', ip => '10.8.0.108'},
    {host => 'notification.adblockplus.org', ip => '10.8.0.112'},
    {host => 'update.adblockplus.org', ip => '10.8.0.116'},
    {host => 'stats.adblockplus.org', ip => '10.8.0.117'},
    {host => 'server_1.adblockplus.org', ip => '10.8.0.97'},
    {host => 'server_3.adblockplus.org', ip => '10.8.0.98'},
    {host => 'server_4.adblockplus.org', ip => '10.8.0.99'},
    {host => 'server_5.adblockplus.org', ip => '10.8.0.100'},
    {host => 'server_6.adblockplus.org', ip => '10.8.0.101'},
    {host => 'server_7.adblockplus.org', ip => '10.8.0.102'},
    {host => 'server_8.adblockplus.org', ip => '10.8.0.103'},
    {host => 'server_9.adblockplus.org', ip => '10.8.0.104'},
    {host => 'server_10.adblockplus.org', ip => '10.8.0.105'},
    {host => 'server_11.adblockplus.org', ip => '10.8.0.106'},
    {host => 'server_12.adblockplus.org', ip => '10.8.0.107'},
    {host => 'server_13.adblockplus.org', ip => '10.8.0.108'},
    {host => 'server_14.adblockplus.org', ip => '10.8.0.109'},
    {host => 'server_15.adblockplus.org', ip => '10.8.0.110'},
    {host => 'server_17.adblockplus.org', ip => '10.8.0.112'},
    {host => 'server_18.adblockplus.org', ip => '10.8.0.113'},
    {host => 'server_19.adblockplus.org', ip => '10.8.0.114'},
    {host => 'server_20.adblockplus.org', ip => '10.8.0.115'},
    {host => 'server_21.adblockplus.org', ip => '10.8.0.116'},
    {host => 'server_22.adblockplus.org', ip => '10.8.0.117'},
    {host => 'notification1.adblockplus.org', ip => '10.8.0.118'},
    {host => 'notification2.adblockplus.org', ip => '10.8.0.119'},
    {host => 'filter1.adblockplus.org', ip => '10.8.0.120'},
  ]

  hostentry { $hosts: }
}
