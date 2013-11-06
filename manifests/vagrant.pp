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
    {host => 'server_4.adblockplus.org', ip => '10.8.0.99'},
    {host => 'server_5.adblockplus.org', ip => '10.8.0.100'},
    {host => 'server_6.adblockplus.org', ip => '10.8.0.101'},
    {host => 'server_7.adblockplus.org', ip => '10.8.0.102'},
    {host => 'server_10.adblockplus.org', ip => '10.8.0.105'},
    {host => 'server_11.adblockplus.org', ip => '10.8.0.106'},
    {host => 'server_12.adblockplus.org', ip => '10.8.0.107'},
    {host => 'server_15.adblockplus.org', ip => '10.8.0.110'},
    {host => 'server_19.adblockplus.org', ip => '10.8.0.114'},
    {host => 'server_21.adblockplus.org', ip => '10.8.0.116'},
    {host => 'server_22.adblockplus.org', ip => '10.8.0.117'},
    {host => 'notification1.adblockplus.org', ip => '10.8.0.118'},
    {host => 'notification2.adblockplus.org', ip => '10.8.0.119'},
    {host => 'filter1.adblockplus.org', ip => '10.8.0.120'},
    {host => 'filter2.adblockplus.org', ip => '10.8.0.121'},
    {host => 'filter3.adblockplus.org', ip => '10.8.0.122'},
    {host => 'filter4.adblockplus.org', ip => '10.8.0.123'},
    {host => 'filter5.adblockplus.org', ip => '10.8.0.124'},
    {host => 'filter6.adblockplus.org', ip => '10.8.0.125'},
    {host => 'download1.adblockplus.org', ip => '10.8.0.126'},
  ]

  hostentry { $hosts: }
}
