class web::server(
    $vhost,
    $repository,
    $certificate = hiera('web::server::certificate', 'undef'),
    $private_key = hiera('web::server::private_key', 'undef'),
    $is_default = false,
    $aliases = undef,
    $custom_config = undef,
    $multiplexer_locations = undef,
    $geoip = false,
) {

  include sitescripts

  # Ensure there is at least one character in the respective strings;
  # see https://codereview.adblockplus.org/29329028/#msg3
  validate_re($vhost, '.+')
  validate_re($repository, '.+')

  File {
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
  }

  Cron {
    environment => concat(hiera('cron::environment', []), [
      'PYTHONPATH=/opt/cms:/opt/sitescripts',
    ]),
  }

  class {'nginx':
    geoip_country => $geoip ? {
      false => undef,
      default => '/usr/share/GeoIP/GeoIPv6.dat',
    },
  }

  class {'geoip':
    cron => {hour => 0, minute => 8, monthday => 15},
    ensure => $geoip ? {false => 'absent', default => 'present'},
  }

  ensure_packages(['python-pip'])

  # Make sure that apt packages corresponding to the pip-installed modules below
  # won't be installed unintentionally, these will take precedence otherwise.
  package {['python-jinja2', 'python-markdown']:
    ensure => 'held',
  }

  package {'Jinja2':
    ensure => '2.8',
    provider => 'pip',
    require => [Package['python-pip'], Package['python-jinja2']],
  }

  package {'markdown':
    ensure => '2.6.6',
    provider => 'pip',
    require => [Package['python-pip'], Package['python-markdown']],
  }

  nginx::hostconfig {$vhost:
    content => template('web/site.conf.erb'),
    global_config => template('web/global.conf.erb'),
    is_default => $is_default,
    certificate => $certificate ? {'undef' => undef, default => $certificate},
    private_key => $private_key ? {'undef' => undef, default => $private_key},
    log => "access_log_$vhost"
  }

  sitescripts::configfragment {$title:
    source => 'puppet:///modules/web/sitescripts',
  }

  if $multiplexer_locations != undef {
    include spawn-fcgi
    package {'python-flup':}

    spawn-fcgi::pool {"multiplexer":
      ensure => present,
      fcgi_app => '/opt/sitescripts/multiplexer.fcgi',
      socket => '/tmp/multiplexer-fastcgi.sock',
      mode => '0666',
      user => 'nginx',
      children => 1,
      require => [
        Class["sitescripts"],
        Package["python-flup"],
      ],
    }
  }

  user {'www':
    ensure => present,
    comment => 'Web content owner',
    home => '/home/www',
    managehome => true,
  }

  exec {"fetch_cms":
    command => "hg clone https://hg.adblockplus.org/cms/ /opt/cms",
    path => ["/usr/bin/", "/bin/"],
    require => Package['mercurial'],
    timeout => 0,
    onlyif => "test ! -d /opt/cms",
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

  file {[
    "/var/cache/$repository",
    "/var/www/$vhost",
    "/var/www/docs",
  ]:
    ensure => directory,
    owner => www,
    mode => 755,
  }

  cron {'update_cms':
    ensure => present,
    command => "hg pull -q -u -R /opt/cms",
    minute  => '5-55/10',
  }

  cron {'update_repo':
    ensure => present,
    command => "hg pull -q -R /home/www/${repository} && python -m cms.bin.generate_static_pages /home/www/${repository} /var/www/${vhost}",
    user => www,
    minute  => '*/10',
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
    ensure => present,
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
}
