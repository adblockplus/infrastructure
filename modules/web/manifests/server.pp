class web::server($vhost, $repository, $multiplexer_locations = undef) {
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
    content => template('web/site.erb'),
    enabled => true,
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.key':
    ensure => file,
    mode => 0400,
    require => Nginx::Hostconfig[$vhost],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.key',
  }

  file {'/etc/nginx/sites-available/adblockplus.org_sslcert.pem':
    ensure => file,
    mode => 0400,
    require => Nginx::Hostconfig[$vhost],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.pem',
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
