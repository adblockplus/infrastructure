class discourse inherits private::discourse {
  include postgresql::server

  postgresql::database {'discourse':}

  postgresql::role {'discourse':
    password_hash => 'vagrant',
    db => 'discourse',
    login => true,
    superuser => true
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
                       'libxslt-dev', 'libpq-dev', 'libfcgi-dev']
  package {$gem_dependencies: ensure => present}

  file {'/opt/discourse':
    ensure => directory,
    mode => 755,
    owner => discourse,
    group => www-data
  }

  file {'/opt/discourse/discourse.fcgi':
    mode => 755,
    owner => discourse,
    group => www-data,
    source => 'puppet:///modules/discourse/discourse.fcgi',
    require => Exec['fetch-discourse']
  }

  file {'/opt/discourse/config/database.yml':
    mode => 600,
    owner => discourse,
    group => www-data,
    source => 'puppet:///modules/discourse/database.yml',
    require => Exec['fetch-discourse']
  }

  file {'/opt/discourse/config/redis.yml':
    mode => 600,
    owner => discourse,
    group => www-data,
    source => 'puppet:///modules/discourse/redis.yml',
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
    environment => ["DISCOURSE_SECRET=${secret}"],
    user => discourse,
    group => www-data,
    require => [Package['mercurial'], File['/opt/discourse']],
    onlyif => "test ! -d /opt/discourse/.hg"
  }

  exec {'/usr/local/bin/init-discourse':
    subscribe => File['/usr/local/bin/init-discourse'],
    refreshonly => true,
    user => discourse,
    group => www-data,
    timeout => 0,
    logoutput => true,
    require => [Package['bundler', 'postgresql-contrib', $gem_dependencies],
                User['discourse'], File['/etc/sudoers.d/discourse'],
                Exec['fetch-discourse'],
                File['/opt/discourse/discourse.fcgi'],
                File['/opt/discourse/config/database.yml'],
                File['/opt/discourse/config/redis.yml']]
  }

  discourse::sitesetting {'title':
    ensure => present,
    type => 1,
    value => 'Adblock Plus internal discussions',
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::sitesetting {'notification_email':
    ensure => present,
    type => 1,
    value => 'donotreply@adblockplus.org',
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::sitesetting {'must_approve_users':
    ensure => present,
    type => 5,
    value => 't',
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::sitesetting {'email_domains_blacklist':
    ensure => present,
    type => 1,
    value => '',
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::sitesetting {'use_ssl':
    ensure => present,
    type => 5,
    value => 't',
    require => Exec['/usr/local/bin/init-discourse']
  }

  discourse::admin {$admins:
    ensure => present,
    require => Exec['/usr/local/bin/init-discourse']
  }

  class {'spawn-fcgi':}

  spawn-fcgi::pool {'discourse-fastcgi':
    ensure => 'present',
    user => 'discourse',
    group => 'www-data',
    mode => 0664,
    fcgi_app => '/opt/discourse/discourse.fcgi',
    socket => '/tmp/discourse-fastcgi.sock',
    require => File['/opt/discourse/discourse.fcgi'],
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
