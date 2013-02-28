class discourse inherits private::discourse {
  include postgresql::server

  postgresql::database {'discourse':}

  postgresql::role {'discourse':
    password_hash => $database_password,
    db => 'discourse',
    login => true,
    superuser => true,
    require => Postgresql::Database['discourse']
  }

  package {['postgresql-contrib', 'redis-server', 'ruby1.9.1']:
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
    before => Package['bundler']
  }

  package {'bundler':
    ensure => present,
    provider => gem
  }

  $gem_dependencies = ['git', 'build-essential', 'ruby1.9.1-dev', 'libxml2-dev',
                       'libxslt-dev', 'libpq-dev']
  package {$gem_dependencies: ensure => present}

  file {'/opt/discourse':
    ensure => directory,
    mode => 755,
    owner => discourse,
    group => www-data
  }

  file {'/opt/discourse/config/database.yml':
    mode => 600,
    owner => discourse,
    group => www-data,
    content => template('discourse/database.yml.erb'),
    notify => Service['discourse-thin'],
    require => Exec['fetch-discourse']
  }

  file {'/opt/discourse/config/redis.yml':
    mode => 600,
    owner => discourse,
    group => www-data,
    source => 'puppet:///modules/discourse/redis.yml',
    notify => Service['discourse-thin'],
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
    onlyif => "test ! -d /opt/discourse/.hg"
  }

  exec {'/usr/local/bin/init-discourse':
    subscribe => File['/usr/local/bin/init-discourse'],
    refreshonly => true,
    environment => ["DISCOURSE_SECRET=${secret}", "AIRBRAKE_KEY=${airbrake_key}"],
    user => discourse,
    group => www-data,
    timeout => 0,
    logoutput => true,
    require => [Package['bundler', 'postgresql-contrib', $gem_dependencies],
                User['discourse'], File['/etc/sudoers.d/discourse'],
                Exec['fetch-discourse'],
                File['/opt/discourse/config/database.yml'],
                File['/opt/discourse/config/redis.yml'],
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

  discourse::sitesetting {'must_approve_users':
    ensure => present,
    type => 5,
    value => 't'
  }

  discourse::sitesetting {'email_domains_blacklist':
    ensure => present,
    type => 1,
    value => ''
  }

  discourse::sitesetting {'use_ssl':
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

  discourse::sitesetting {'secret_token':
    ensure => present,
    type => 1,
    value => $cookie_secret
  }

  Discourse::Postactiontype <| |> {
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::postactiontype {'bookmark':
    ensure => present,
    id => 1,
    position => 1
  }

  discourse::postactiontype {'like':
    ensure => present,
    id => 2,
    position => 2,
    icon => 'heart'
  }

  discourse::postactiontype {'off_topic':
    ensure => present,
    id => 3,
    position => 3,
    is_flag => true
  }

  discourse::postactiontype {'inappropriate':
    ensure => present,
    id => 4,
    position => 4,
    is_flag => true
  }

  discourse::postactiontype {'vote':
    ensure => present,
    position => 0,
    id => 5
  }

  discourse::postactiontype {'custom_flag':
    ensure => present,
    id => 6,
    position => 7,
    is_flag => true
  }

  discourse::postactiontype {'illegal':
    ensure => present,
    id => 7,
    position => 5,
    is_flag => true
  }

  discourse::postactiontype {'spam':
    ensure => present,
    id => 8,
    position => 6,
    is_flag => true
  }

  discourse::admin {$admins:
    ensure => present,
    require => Exec['/usr/local/bin/init-discourse']
  }

  Discourse::Customservice <| |> {
    user => 'discourse',
    workdir => '/opt/discourse',
    env => ['GEM_HOME=~discourse/.gems', 'RAILS_ENV=production'],
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::customservice {'discourse-thin':
    command => 'bundle exec thin -S /tmp/discourse-thin.sock start'
  }

  discourse::customservice {'sidekiq':
    command => 'bundle exec sidekiq'
  }

  discourse::customservice {'clockwork':
    command => 'bundle exec clockwork config/clock.rb'
  }

  class {'nginx':
    worker_processes => 1,
    worker_connections => 500
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.key':
    ensure => file,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['intraforum.adblockplus.org'],
    require => Package['nginx'],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.key'
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.pem':
    ensure => file,
    mode => 0400,
    notify => Service['nginx'],
    before => Nginx::Hostconfig['intraforum.adblockplus.org'],
    require => Package['nginx'],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.pem'
  }

  nginx::hostconfig{'intraforum.adblockplus.org':
    source => 'puppet:///modules/discourse/intraforum.adblockplus.org',
    enabled => true
  }

  file {'/etc/logrotate.d/nginx_intraforum.adblockplus.org':
    ensure => file,
    require => Nginx::Hostconfig['intraforum.adblockplus.org'],
    source => 'puppet:///modules/discourse/logrotate'
  }
}
