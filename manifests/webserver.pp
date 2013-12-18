node 'web1' {
  include base

  class {'web::server':
    vhost => 'eyeo.com',
    repository => 'web.eyeo.com',
    multiplexer_locations => ['/formmail'],
  }

  concat::fragment {'formmail_template':
    target => '/etc/sitescripts.ini',
    content => "[DEFAULT]\nmailer=/usr/sbin/sendmail\n[formmail]\ntemplate=formmail/template/eyeo.mail\n",
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
