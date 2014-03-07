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
    {host => 'notification1.adblockplus.org', ip => '10.8.0.118'},
    {host => 'notification2.adblockplus.org', ip => '10.8.0.119'},
    {host => 'filter1.adblockplus.org', ip => '10.8.0.120'},
    {host => 'filter2.adblockplus.org', ip => '10.8.0.121'},
    {host => 'filter3.adblockplus.org', ip => '10.8.0.122'},
    {host => 'filter4.adblockplus.org', ip => '10.8.0.123'},
    {host => 'filter5.adblockplus.org', ip => '10.8.0.124'},
    {host => 'filter6.adblockplus.org', ip => '10.8.0.125'},
    {host => 'download1.adblockplus.org', ip => '10.8.0.126'},
    {host => 'filtermaster1.adblockplus.org', ip => '10.8.0.127'},
    {host => 'update1.adblockplus.org', ip => '10.8.0.128'},
    {host => 'web1.adblockplus.org', ip => '10.8.0.129'},
    {host => 'stats1.adblockplus.org', ip => '10.8.0.130'},
    {host => 'issues1.adblockplus.org', ip => '10.8.0.131'},
    {host => 'codereview1.adblockplus.org', ip => '10.8.0.132'},
    {host => 'filter7.adblockplus.org', ip => '10.8.0.133'},
    {host => 'filter8.adblockplus.org', ip => '10.8.0.134'},
    {host => 'filter9.adblockplus.org', ip => '10.8.0.135'},
    {host => 'filter10.adblockplus.org', ip => '10.8.0.136'},
    {host => 'filter11.adblockplus.org', ip => '10.8.0.137'},
    {host => 'filter12.adblockplus.org', ip => '10.8.0.138'},
    {host => 'filter13.adblockplus.org', ip => '10.8.0.139'},
    {host => 'filter14.adblockplus.org', ip => '10.8.0.140'},
    {host => 'filter15.adblockplus.org', ip => '10.8.0.141'},
    {host => 'filter16.adblockplus.org', ip => '10.8.0.142'},
    {host => 'filter17.adblockplus.org', ip => '10.8.0.143'},
    {host => 'filter18.adblockplus.org', ip => '10.8.0.144'},
  ]

  hostentry { $hosts: }
}
