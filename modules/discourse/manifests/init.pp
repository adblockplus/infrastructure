class discourse(
    $domain,
    $certificate,
    $private_key,
    $is_default = false
  ) inherits private::discourse {

  class { 'postgresql::globals':
    manage_package_repo => true,
    version => '9.3',
  }->
  class {"postgresql::server":}

  class {"postgresql::server::contrib":
    package_ensure => 'present',
  }

  postgresql::server::database {'discourse':}

  postgresql::server::role {'discourse':
    password_hash => postgresql_password('discourse', $database_password),
    db => 'discourse',
    login => true,
    superuser => true,
    require => Postgresql::Server::Database['discourse']
  }

  $rvm_dependencies = ['curl', 'git-core', 'patch', 'build-essential', 'bison',
      'zlib1g-dev', 'libssl-dev', 'libxml2-dev', 'sqlite3', 'libsqlite3-dev',
      'autotools-dev', 'libxslt1-dev', 'libyaml-0-2', 'autoconf', 'automake',
      'libreadline6-dev', 'libyaml-dev', 'libtool', 'libgdbm-dev',
      'libncurses5-dev', 'libffi-dev', 'pkg-config', 'gawk']
  $discourse_dependencies = ['redis-server', 'libjemalloc1']
  $gem_dependencies = ['libpq-dev']
  $image_optim_dependencies = ['advancecomp', 'gifsicle', 'jhead', 'jpegoptim',
      'libjpeg-progs', 'optipng', 'pngcrush']
  $image_sorcery_dependencies = 'imagemagick'

  package {[$rvm_dependencies, $discourse_dependencies, $gem_dependencies, $image_optim_dependencies, $image_sorcery_dependencies]:
    ensure => present
  }

  Exec <| tag == 'rvm' |> {
    path => '/bin:/usr/bin:/usr/sbin:/usr/local/bin:/home/discourse/.rvm/bin',
    user => discourse,
    group => www-data,
    environment => ['HOME=/home/discourse'],
  }

  exec {'install-rvm-key':
    command => 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3',
    tag => 'rvm',
    unless => 'gpg --list-keys | grep D39DC0E3',
  }

  exec {'install-ruby':
    command => 'curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.2',
    tag => 'rvm',
    creates => '/home/discourse/.rvm',
    timeout => 0,
    logoutput => true,
    require => [Exec['install-rvm-key'], Package[$rvm_dependencies]],
  }

  exec {'install-bundler':
    command => 'rvm default do gem install bundler',
    tag => 'rvm',
    unless => 'rvm default do gem list | grep "^bundler ")',
    require => Exec['install-ruby'],
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
    timeout => 0,
    require => [Package['mercurial'], File['/opt/discourse']],
    notify => Exec['init-discourse'],
    onlyif => "test ! -d /opt/discourse/.hg"
  }

  file {'/opt/discourse/config/initializers/airbrake.rb':
    ensure => absent,
    before => Exec['init-discourse'],
  }

  file {'/opt/discourse/config/version.rb':
    ensure => present,
    owner => discourse,
    group => www-data,

    # This is hardcoded here so that Discourse doesn't try to extract it from
    # the repository. Ideally, we should update it when updating Discourse.
    content => '$git_version = "8a3a02421a39f53b6adf3ca9a6fdba73f42bc932"',
    require => Exec['fetch-discourse'],
    before => Exec['init-discourse'],
  }

  exec {'init-discourse':
    command => 'rvm default do /usr/local/bin/init-discourse',
    tag => 'rvm',
    subscribe => File['/usr/local/bin/init-discourse'],
    refreshonly => true,
    timeout => 0,
    logoutput => true,
    require => [Exec['install-bundler'],
                Package[$discourse_dependencies, $gem_dependencies],
                User['discourse'], File['/etc/sudoers.d/discourse'],
                Exec['fetch-discourse'],
                File['/opt/discourse/config/discourse.conf'],
                Postgresql::Server::Role['discourse']]
  }

  Discourse::Sitesetting <| |> {
    require => Exec['init-discourse']
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

  discourse::sitesetting {'enable_google_logins':
    ensure => present,
    type => 5,
    value => 'f'
  }

  discourse::sitesetting {'enable_google_oauth2_logins':
    ensure => present,
    type => 5,
    value => 't'
  }

  discourse::sitesetting {'google_oauth2_client_id':
    ensure => present,
    type => 1,
    value => $google_client_id
  }

  discourse::sitesetting {'google_oauth2_client_secret':
    ensure => present,
    type => 1,
    value => $google_client_secret
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

  Customservice {
    user => 'discourse',
    workdir => '/opt/discourse',
    env => ['RAILS_ENV=production', 'RUBY_GC_MALLOC_LIMIT=90000000',
      'UNICORN_WORKERS=2', 'LD_PRELOAD=/usr/lib/libjemalloc.so.1'],
    require => Exec['init-discourse']
  }

  customservice {'discourse':
    command => '/home/discourse/.rvm/bin/rvm default do bundle exec config/unicorn_launcher -c config/unicorn.conf.rb',
    require => File['/opt/discourse/tmp/pids'],
  }

  customservice {'sidekiq':
    command => '/home/discourse/.rvm/bin/rvm default do bundle exec sidekiq'
  }

  class {'nginx':
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
