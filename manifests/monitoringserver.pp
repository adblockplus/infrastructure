node 'server4' {
  include base

  class {'nagios::client':
    server_address => 'localhost'
  }
  
  class {'nagios::server':
    htpasswd_source => 'puppet:///modules/private/nagios-htpasswd',
    admins => ['fhd']
  }

  nagios_host {'localhost': use => 'generic-host'}
  nagios_host {'www.adblockplus.org': use => 'generic-host'}

  nagios_hostgroup {'all': members => '*'}
  nagios_hostgroup {'http-servers': members => 'localhost, www.adblockplus.org'}

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
}
