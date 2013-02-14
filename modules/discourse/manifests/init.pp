class discourse {
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

  $gem_dependencies = ['build-essential', 'libxml2-dev', 'libxslt-dev',
                       'libpq-dev']
  package {$gem_dependencies: ensure => present}

  file {'/etc/discourse': ensure => directory}

  file {'/etc/discourse/database.yml':
    mode => 640,
    owner => root,
    group => root,
    source => 'puppet:///modules/discourse/database.yml'
  }

  file {'/etc/discourse/redis.yml':
    mode => 640,
    owner => root,
    group => root,
    source => 'puppet:///modules/discourse/redis.yml'
  }

  file {'/usr/local/bin/deploy-discourse':
    mode => 0744,
    owner => root,
    group => root,
    source => 'puppet:///modules/discourse/deploy-discourse'
  }

  exec {'/usr/local/bin/deploy-discourse':
    subscribe => File['/usr/local/bin/deploy-discourse'],
    refreshonly => true,
    require => [Package['bundler', 'postgresql-contrib', $gem_dependencies],
                File['/etc/discourse/database.yml', '/etc/discourse/redis.yml']]
  }

  # TODO: Set up thin to run the app, with nginx as a proxy if necessary
}
