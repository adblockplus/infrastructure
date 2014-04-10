node 'server4' {
  include base, ssh, puppetmaster

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }

  class {'nagios::server':
    domain => 'monitoring.adblockplus.org',
    certificate => 'monitoring.adblockplus.org_sslcert.pem',
    private_key => 'monitoring.adblockplus.org_sslcert.key',
    is_default => 'true',
    htpasswd_source => 'puppet:///modules/private/nagios-htpasswd',
    admins => ['*']
  }

  if $::environment == 'development' {
    nagios_contact {'root':
      service_notification_period => '24x7',
      host_notification_period => '24x7',
      service_notification_options => 'w,u,c,r',
      host_notification_options => 'd,r',
      service_notification_commands => 'notify-service-by-email',
      host_notification_commands => 'notify-host-by-email',
      email => 'root@localhost'
    }

    nagios_contactgroup {'admins':
      alias => 'Nagios Administrators',
      members => 'root'
    }
  } else {
    nagios_contact {'abp-admins':
      alias => 'Adblock Plus Administartors',
      service_notification_period => '24x7',
      host_notification_period => '24x7',
      service_notification_options => 'w,u,c,r',
      host_notification_options => 'd,r',
      service_notification_commands => 'notify-service-by-email',
      host_notification_commands => 'notify-host-by-email',
      email => 'admins@adblockplus.org'
    }

    nagios_contactgroup {'admins':
      alias => 'Nagios Administrators',
      members => 'abp-admins'
    }
  }

  nagios_command {'check_nrpe_timeout':
    command_line => '/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t $ARG2$'
  }

  nagios_command {'check_easylist_http':
    command_line => '/usr/lib/nagios/plugins/check_http -S -I $HOSTADDRESS$ -H easylist-downloads.adblockplus.org -u /easylist.txt -k "Accept-Encoding: gzip,deflate" -e "HTTP/1.1 200 OK"'
  }

  nagios_command {'check_notification_http':
    command_line => '/usr/lib/nagios/plugins/check_http -S -I $HOSTADDRESS$ -H notification.adblockplus.org -u /notification.json -k "Accept-Encoding: gzip,deflate" -e "HTTP/1.1 200 OK"'
  }

  nagios_host {'server_4.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_5.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_6.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_7.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_10.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_11.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_12.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_15.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_16.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_19.adblockplus.org': use => 'generic-host'}
  nagios_host {'download1.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter1.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter2.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter3.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter4.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter5.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter6.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter7.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter8.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter9.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter10.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter11.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter12.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter13.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter14.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter15.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter16.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter17.adblockplus.org': use => 'generic-host'}
  nagios_host {'filter18.adblockplus.org': use => 'generic-host'}
  nagios_host {'filtermaster1.adblockplus.org': use => 'generic-host'}
  nagios_host {'notification1.adblockplus.org': use => 'generic-host'}
  nagios_host {'notification2.adblockplus.org': use => 'generic-host'}
  nagios_host {'update1.adblockplus.org': use => 'generic-host'}
  nagios_host {'web1.adblockplus.org': use => 'generic-host'}
  nagios_host {'stats1.adblockplus.org': use => 'generic-host'}
  nagios_host {'issues1.adblockplus.org': use => 'generic-host'}
  nagios_host {'codereview1.adblockplus.org': use => 'generic-host'}

  nagios_hostgroup {'all': members => '*'}
  nagios_hostgroup {'http-servers': members => 'server_4.adblockplus.org, server_10.adblockplus.org, server_16.adblockplus.org, download1.adblockplus.org, update1.adblockplus.org, web1.adblockplus.org, stats1.adblockplus.org, issues1.adblockplus.org, codereview1.adblockplus.org'}
  nagios_hostgroup {'filter-servers': members => 'server_5.adblockplus.org, server_6.adblockplus.org, server_7.adblockplus.org, server_11.adblockplus.org, server_12.adblockplus.org, server_15.adblockplus.org, server_19.adblockplus.org, filter1.adblockplus.org, filter2.adblockplus.org, filter3.adblockplus.org, filter4.adblockplus.org, filter5.adblockplus.org, filter6.adblockplus.org, filter7.adblockplus.org, filter8.adblockplus.org, filter9.adblockplus.org, filter10.adblockplus.org, filter11.adblockplus.org, filter12.adblockplus.org, filter13.adblockplus.org, filter14.adblockplus.org, filter15.adblockplus.org, filter16.adblockplus.org, filter17.adblockplus.org, filter18.adblockplus.org, notification1.adblockplus.org, notification2.adblockplus.org'}

  nagios_service {'current-load':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Current Load',
    check_command => 'check_nrpe_1arg!check_load'
  }

  nagios_service {'disk-space':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Disk Space',
    check_command => 'check_nrpe_1arg!check_disk'
  }

  nagios_service {'total-processes':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Total Processes',
    check_command => 'check_nrpe_1arg!check_total_procs'
  }

  nagios_service {'zombie-processes':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Zombie Processes',
    check_command => 'check_nrpe_1arg!check_zombie_procs'
  }

  nagios_service {'ssh':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'SSH',
    check_command => 'check_ssh'
  }

  nagios_service {'http':
    use => 'generic-service',
    hostgroup_name => 'http-servers',
    service_description => 'HTTP',
    check_command => 'check_http'
  }

  nagios_service {'easylist-http':
    use => 'generic-service',
    hostgroup_name => 'filter-servers',
    service_description => 'HTTP',
    check_command => 'check_easylist_http'
  }

  nagios_service {'notification-http':
    use => 'generic-service',
    hostgroup_name => 'filter-servers',
    service_description => 'HTTP',
    check_command => 'check_notification_http'
  }

  nagios_service {'bandwidth':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Bandwidth',
    check_command => 'check_nrpe_timeout!check_bandwidth!20',
    first_notification_delay => '15'
  }

  nagios_service {'connections':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Connections',
    check_command => 'check_nrpe_1arg!check_connections',
  }

  nagios_service {'memory':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Memory',
    check_command => 'check_nrpe_1arg!check_memory',
  }
}
