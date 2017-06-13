node 'web2' {

  class {'web::server':
    vhost => 'adblockplus.org',
    certificate => 'adblockplus.org_sslcert.pem',
    private_key => 'adblockplus.org_sslcert.key',
    is_default => true,
    aliases => ['www.adblockplus.org'],
    custom_config => template('web/adblockplus.org.conf.erb'),
    repository => 'web.adblockplus.org',
    multiplexer_locations => ['/getSubscription'],
    geoip => true,
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
    environment => hiera('cron::environment', []),
    command => "hg pull --quiet --repository $subscriptions_repo",
    user => 'sitescripts',
    minute => '1-59/20',
    require => Exec['fetch_repository_subscriptionlist']
  }

  # We have to set up the APT source and install the jsdoc package via npm
  # manually. Once we're on Puppet 3, we can use the official nodejs module for
  # all this: https://forge.puppetlabs.com/puppetlabs/nodejs

  apt::source {'nodesource':
    location => 'https://deb.nodesource.com/node_4.x',
    release => 'precise',
    repos => 'main',
    key => '68576280',
    key_content => template('web/nodesource.gpg.key.erb'),
  }

  package {'nodejs':
    require => Apt::Source['nodesource'],
  }

  exec {'install_jsdoc':
    command => 'npm install --global jsdoc',
    path => ['/usr/bin/'],
    require => Package['nodejs'],
    onlyif => 'test ! -x /usr/bin/jsdoc',
  }

  package {['make', 'doxygen']:}

  cron {'generate_docs':
    ensure => 'present',
    require => [
      Class['sitescripts'],
      Exec['install_jsdoc'],
      Package['make', 'doxygen'],
      File['/var/www/docs'],
    ],
    command => 'python -m sitescripts.docs.bin.generate_docs',
    user => www,
    minute => '5-55/10',
  }

  adblockplus::log::rotation {'nginx_email_submission':
    count => 120,
    ensure => 'present',
    interval => 'monthly',
    path => '/var/log/nginx/email_submission',
  }
}
