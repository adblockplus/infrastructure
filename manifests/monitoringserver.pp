node 'server4' {
  include base, ssh

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }

  class {'nagios::server':
    vhost => 'monitoring.adblockplus.org',
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

  nagios_command {'check_easylist_http':
    command_line => '/usr/lib/nagios/plugins/check_http -S -I $HOSTADDRESS$ -H easylist-downloads.adblockplus.org -u /easylist.txt -k "Accept-Encoding: gzip,deflate" -e "HTTP/1.1 200 OK"'
  }

  nagios_host {'www.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_3.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_4.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_5.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_6.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_7.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_8.adblockplus.org': use => 'generic-host'}
  nagios_host {'server_9.adblockplus.org': use => 'generic-host'}

  nagios_hostgroup {'all': members => '*'}
  nagios_hostgroup {'http-servers': members => 'www.adblockplus.org, server_4.adblockplus.org'}
  nagios_hostgroup {'filter-servers': members => 'server_3.adblockplus.org, server_5.adblockplus.org, server_6.adblockplus.org, server_7.adblockplus.org, server_8.adblockplus.org, server_9.adblockplus.org'}

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

  nagios_service {'bandwidth':
    use => 'generic-service',
    hostgroup_name => 'all',
    service_description => 'Bandwidth',
    check_command => 'check_nrpe_1arg!check_bandwidth'
  }
}
