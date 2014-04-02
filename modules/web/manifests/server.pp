class web::server(
    $vhost,
    $repository,
    $is_default = false,
    $aliases = undef,
    $custom_config = undef,
    $multiplexer_locations = undef) {
  File {
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
  }

  Cron {
    environment => ['MAILTO=admins@adblockplus.org', 'PYTHONPATH=/opt/sitescripts'],
  }

  include nginx

  package {['python-jinja2', 'python-markdown']:}

  nginx::hostconfig {$vhost:
    content => template('web/site.conf.erb'),
    global_config => template('web/global.conf.erb'),
    is_default => $is_default,
    certificate => 'adblockplus.org_sslcert.pem',
    private_key => 'adblockplus.org_sslcert.key',
    log => "access_log_$vhost"
  }

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/web/sitescripts',
  }

  if $multiplexer_locations != undef {
    include spawn-fcgi
    package {['python-flup', 'python-mysqldb']:}

    spawn-fcgi::pool {"multiplexer":
      ensure => present,
      fcgi_app => '/opt/sitescripts/multiplexer.fcgi',
      socket => '/tmp/multiplexer-fastcgi.sock',
      mode => '0666',
      user => 'nginx',
      children => 1,
      require => [
        Exec["fetch_sitescripts"],
        Package["python-flup"],
        Package["python-mysqldb"],
      ],
    }
  }

  user {'www':
    ensure => present,
    comment => 'Web content owner',
    home => '/home/www',
    managehome => true,
  }

  exec {"fetch_repo":
    command => "hg clone -U https://hg.adblockplus.org/${repository} /home/www/${repository}",
    path => ["/usr/bin/", "/bin/"],
    require => Package['mercurial'],
    user => www,
    timeout => 0,
    onlyif => "test ! -d /home/www/${repository}",
  }

  file {'/var/www':
    ensure => directory,
    mode => 755,
  }

  file {"/var/www/${vhost}":
    ensure => directory,
    owner => www,
    mode => 755,
  }

  cron {'update_repo':
    ensure => present,
    command => "hg pull -q -R /home/www/${repository} && python -m sitescripts.cms.bin.generate_static_pages /home/www/${repository} /var/www/${vhost}",
    user => www,
    minute  => '*/10',
  }
}
