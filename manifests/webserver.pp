node 'web1' {
  include base, statsclient

  class {'web::server':
    vhost => 'eyeo.com',
    certificate => 'eyeo.com_sslcert.pem',
    private_key => 'eyeo.com_sslcert.key',
    is_default => true,
    aliases => ['www.eyeo.com', 'eyeo.de', 'www.eyeo.de'],
    custom_config => '
      rewrite ^(/de)?/index\.html$ / permanent;
      rewrite ^(/de)?/job\.html$ /jobs permanent;
    ',
    repository => 'web.eyeo.com',
    multiplexer_locations => ['/formmail'],
  }

  concat::fragment {'formmail_template':
    target => '/etc/sitescripts.ini',
    content => '[DEFAULT]
mailer=/usr/sbin/sendmail
[multiplexer]
sitescripts.formmail.web.formmail =
[formmail]
template=formmail/template/eyeo.mail',
  }

  class {'nagios::client':
    server_address => 'monitoring.adblockplus.org'
  }
}
