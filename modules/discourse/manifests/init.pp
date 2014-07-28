class discourse(
    $domain,
    $certificate,
    $private_key,
    $is_default = false
  ) inherits private::discourse {

  include postgresql::server

  postgresql::database {'discourse':}

  postgresql::role {'discourse':
    password_hash => $database_password,
    db => 'discourse',
    login => true,
    superuser => true,
    require => Postgresql::Database['discourse']
  }

  $basic_dependencies = ['postgresql-contrib', 'redis-server', 'ruby1.9.1',
      'libjemalloc1', 'curl']
  $gem_dependencies = ['git', 'build-essential', 'ruby1.9.1-dev', 'libxml2-dev',
      'libxslt-dev', 'libpq-dev']
  $image_optim_dependencies = ['advancecomp', 'gifsicle', 'jhead', 'jpegoptim',
      'libjpeg-progs', 'optipng', 'pngcrush']
  $image_sorcery_dependencies = 'imagemagick'

  package {[$basic_dependencies, $gem_dependencies, $image_optim_dependencies, $image_sorcery_dependencies]:
    ensure => present
  }

  Exec {path => '/bin:/usr/bin:/usr/sbin:/usr/local/bin'}

  exec {'update-alternatives --set ruby "/usr/bin/ruby1.9.1"':
    unless => 'test $(readlink "/etc/alternatives/ruby") == "/usr/bin/ruby1.9.1"',
    require => Package['ruby1.9.1']
  }

  exec {'update-alternatives --set gem "/usr/bin/gem1.9.1"':
    unless => 'test $(readlink "/etc/alternatives/gem") == "/usr/bin/gem1.9.1"',
    require => Package['ruby1.9.1'],
    before => Exec['update_gem']
  }

  exec {'update_gem':
    command => '/usr/bin/gem update --system 1.8.25',
    unless => 'test $(gem -v) == "1.8.25"',
    environment => 'REALLY_GEM_UPDATE_SYSTEM=1',
  }

  package {'bundler':
    ensure => present,
    provider => gem,
    require => Exec['update_gem']
  }

  file {'/opt/discourse':
    ensure => directory,
    mode => 755,
    owner => discourse,
    group => www-data
  }

  file {['/opt/discourse/tmp', '/opt/discourse/tmp/pids']:
    ensure => directory,
    mode => 755,
    owner => discourse,
    group => www-data,
    require => Exec['fetch-discourse']
  }

  file {'/opt/discourse/config/discourse.conf':
    mode => 600,
    owner => discourse,
    group => www-data,
    content => template('discourse/discourse.conf.erb'),
    notify => Service['discourse'],
    require => Exec['fetch-discourse']
  }

  file {'/usr/local/bin/init-discourse':
    mode => 0755,
    owner => root,
    group => root,
    source => 'puppet:///modules/discourse/init-discourse'
  }

  user {'discourse':
    ensure => present,
    comment => 'Discourse user',
    home => '/home/discourse',
    gid => www-data,
    password => '*',
    managehome => true
  }

  file {'/etc/sudoers.d/discourse':
    ensure => present,
    owner => root,
    group => root,
    mode => 0440,
    source => 'puppet:///modules/discourse/sudoers',
    require => User['discourse']
  }

  exec {'fetch-discourse':
    command => "hg clone https://hg.adblockplus.org/discourse /opt/discourse",
    path => ["/usr/bin/", "/bin/"],
    user => discourse,
    group => www-data,
    require => [Package['mercurial'], File['/opt/discourse']],
    notify => Exec['/usr/local/bin/init-discourse'],
    onlyif => "test ! -d /opt/discourse/.hg"
  }

  exec {'/usr/local/bin/init-discourse':
    subscribe => File['/usr/local/bin/init-discourse'],
    refreshonly => true,
    environment => ["AIRBRAKE_KEY=${airbrake_key}"],
    user => discourse,
    group => www-data,
    timeout => 0,
    logoutput => true,
    require => [Package['bundler', $gem_dependencies],
                User['discourse'], File['/etc/sudoers.d/discourse'],
                Exec['fetch-discourse'],
                File['/opt/discourse/config/discourse.conf'],
                Postgresql::Role['discourse']]
  }

  Discourse::Sitesetting <| |> {
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::sitesetting {'title':
    ensure => present,
    type => 1,
    value => 'Adblock Plus internal discussions'
  }

  discourse::sitesetting {'notification_email':
    ensure => present,
    type => 1,
    value => 'donotreply@adblockplus.org'
  }

  discourse::sitesetting {'contact_email':
    ensure => present,
    type => 1,
    value => 'admins@adblockplus.org'
  }

  discourse::sitesetting {'site_contact_username':
    ensure => present,
    type => 1,
    value => 'system'
  }

  discourse::sitesetting {'must_approve_users':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'login_required':
    ensure => present,
    type => 5,
    value => 't'
  }

  discourse::sitesetting {'email_domains_blacklist':
    ensure => present,
    type => 1,
    value => ''
  }

  discourse::sitesetting {'email_domains_whitelist':
    ensure => present,
    type => 1,
    value => 'adblockplus.org|eyeo.com'
  }

  discourse::sitesetting {'use_https':
    ensure => present,
    type => 5,
    value => 't'
  }

  discourse::sitesetting {'company_full_name':
    ensure => present,
    type => 1,
    value => 'Eyeo GmbH'
  }

  discourse::sitesetting {'company_short_name':
    ensure => present,
    type => 1,
    value => 'Eyeo'
  }

  discourse::sitesetting {'company_domain':
    ensure => present,
    type => 1,
    value => 'eyeo.com'
  }

  discourse::sitesetting {'enable_local_logins':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'enable_local_account_create':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'enable_facebook_logins':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'enable_twitter_logins':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'enable_github_logins':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'enable_yahoo_logins':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'enforce_global_nicknames':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'allow_user_locale':
    ensure => present,
    type => 5,
    value => 't'
  }

  discourse::sitesetting {'white_listed_spam_host_domains':
    ensure => present,
    type => 1,
    value => 'adblockplus.org,eyeo.com'
  }

  discourse::sitesetting {'max_mentions_per_post':
    ensure => present,
    type => 3,
    value => '50',
  }

  Discourse::Customservice <| |> {
    user => 'discourse',
    workdir => '/opt/discourse',
    env => ['RAILS_ENV=production', 'RUBY_GC_MALLOC_LIMIT=90000000',
      'UNICORN_WORKERS=2', 'LD_PRELOAD=/usr/lib/libjemalloc.so.1'],
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::customservice {'discourse':
    command => 'bundle exec config/unicorn_launcher -c config/unicorn.conf.rb',
    require => File['/opt/discourse/tmp/pids'],
  }

  discourse::customservice {'sidekiq':
    command => 'bundle exec sidekiq'
  }

  class {'nginx':
    worker_processes => 1,
    worker_connections => 500
  }

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/discourse/site.conf',
    global_config => '
      upstream discourse {
        server localhost:3000;
      }',
    is_default => $is_default,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_intraforum'
  }
}
