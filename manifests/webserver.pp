node 'web1' {
  include statsclient

  class {'web::server':
    vhost => 'eyeo.com',
    certificate => 'eyeo.com_sslcert.pem',
    private_key => 'eyeo.com_sslcert.key',
    is_default => true,
    aliases => ['www.eyeo.com', 'eyeo.de', 'www.eyeo.de'],
    custom_config => '
      rewrite ^(/de)?/index\.html$ / permanent;
      rewrite ^(/de)?/job\.html$ /jobs permanent;

      location ~ ^(/[^/]+/jobs)/
      {
        error_page 404 $1/not-available;
      }
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
}

node 'web2' {
  include statsclient

  class {'web::server':
    vhost => 'adblockplus.org',
    certificate => 'adblockplus.org_sslcert.pem',
    private_key => 'adblockplus.org_sslcert.key',
    is_default => true,
    aliases => ['www.adblockplus.org'],
    custom_config => template('web/adblockplus.org.conf.erb'),
    repository => 'web.adblockplus.org',
    multiplexer_locations => ['/getSubscription'],
  }

  $sitescripts_var_dir = '/var/lib/sitescripts'
  $subscriptions_repo = "${sitescripts_var_dir}/subscriptionlist"

  concat::fragment {'formmail_template':
    target => '/etc/sitescripts.ini',
    content => "
[multiplexer]
sitescripts.subscriptions.web.fallback =
[subscriptions]
repository=$sitescripts_var_dir/subscriptionlist",
  }

  user {'sitescripts':
    ensure => present,
    home => $sitescripts_var_dir
  }

  file {$sitescripts_var_dir:
    ensure => directory,
    mode => 0755,
    owner => 'sitescripts',
    group => 'sitescripts'
  }

  exec {'fetch_repository_subscriptionlist':
    command => "hg clone --noupdate https://hg.adblockplus.org/subscriptionlist $subscriptions_repo",
    path => '/usr/local/bin:/usr/bin:/bin',
    user => 'sitescripts',
    timeout => 0,
    onlyif => "test ! -d $subscriptions_repo",
    require => [Package['mercurial'], File[$sitescripts_var_dir]]
  }

  cron {'update_repository_subscriptionlist':
    ensure => present,
    environment => ['MAILTO=admins@adblockplus.org'],
    command => "hg pull --quiet --repository $subscriptions_repo",
    user => 'sitescripts',
    minute => '*/10',
    require => Exec['fetch_repository_subscriptionlist']
  }
}

node 'web3' {
  include statsclient

  class {'web::server':
    vhost => 'testpages.adblockplus.org',
    certificate => 'testpages.adblockplus.org_sslcert.pem',
    private_key => 'testpages.adblockplus.org_sslcert.key',
    is_default => true,
    repository => 'testpages.adblockplus.org',
  }
}

node 'web-sh-abp-org-1' {
  include statsclient

  class {'web::server':
    vhost => 'share.adblockplus.org',
    certificate => 'share.adblockplus.org_sslcert.pem',
    private_key => 'share.adblockplus.org_sslcert.key',
    is_default => true,
    repository => 'share.adblockplus.org',
  }
}

node 'web-yt-abp-me-1' {
  include statsclient

  class {'web::server':
    vhost => 'youtube.adblockplus.me',
    certificate => 'youtube.adblockplus.me_sslcert.pem',
    private_key => 'youtube.adblockplus.me_sslcert.key',
    is_default => true,
    repository => 'youtube.adblockplus.me',
  }
}

node 'web-fb-abp-me-1' {
  include statsclient

  class {'web::server':
    vhost => 'facebook.adblockplus.me',
    certificate => 'facebook.adblockplus.me_sslcert.pem',
    private_key => 'facebook.adblockplus.me_sslcert.key',
    is_default => true,
    repository => 'facebook.adblockplus.me',
  }
}

node 'web-aa-org-1' {
  include statsclient

  class {'web::server':
    vhost => 'acceptableads.org',
    certificate => 'acceptableads.org_sslcert.pem',
    private_key => 'acceptableads.org_sslcert.key',
    is_default => true,
    repository => 'web.acceptableads.org',
  }
}
