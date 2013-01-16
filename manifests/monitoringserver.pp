node default {
  include base

  class {'nagios::server':
    htpasswd_source => 'puppet:///modules/private/nagios-htpasswd'
  }
}
