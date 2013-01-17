node default {
  include base

  class {'nagios::server':
    htpasswd_source => 'puppet:///modules/private/nagios-htpasswd'
  }

  nagios_host {'10.8.0.97': use => 'generic-host'}
  nagios_hostgroup {'all': members => '*'}
  nagios_hostgroup {'ssh-servers': members => 'localhost, 10.8.0.97'}
  nagios_hostgroup {'http-servers': members => 'localhost, 10.8.0.97'}
}
