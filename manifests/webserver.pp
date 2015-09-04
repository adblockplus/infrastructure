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
