class web::server(
    $vhost,
    $repository,
    $certificate = hiera('web::server::certificate', 'undef'),
    $private_key = hiera('web::server::private_key', 'undef'),
    $is_default = false,
    $aliases = undef,
    $custom_config = undef,
    $multiplexer_locations = undef,
    $custom_global_config = undef,
    $vcs = 'git',
) {

  include sitescripts
  include adblockplus::web
  include adblockplus::git
  include geoip

  $pythonpath = 'PYTHONPATH=/opt/cms:/opt/sitescripts'

  # Ensure there is at least one character in the respective strings;
  # see https://codereview.adblockplus.org/29329028/#msg3
  validate_re($vhost, '.+')
  validate_re($repository, '.+')

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  Cron {
    environment => concat(hiera('cron::environment', []), [
      $pythonpath,
    ]),
  }

  class {'nginx':
    geoip_country => '/usr/share/GeoIP/GeoIPv4.dat',
  }

  nginx::module{'geoip':
    path => 'modules/ngx_http_geoip_module.so',
  }

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
    ensure => '2.6.8',
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

  if $multiplexer_locations != undef {
    include spawn_fcgi

    spawn_fcgi::pool {"multiplexer":
      ensure => present,
      fcgi_app => '/opt/sitescripts/multiplexer.fcgi',
      socket => '/tmp/multiplexer-fastcgi.sock',
      mode => '0666',
      user => 'nginx',
      children => 1,
      require => [
        Class["sitescripts"],
      ],
    }
  }

  $cms_vcs_creates = "/opt/cms/.git/config"
  $fetch_cms_cmd = [
    'git', 'clone',
    'https://gitlab.com/eyeo/websites/cms',
    '/opt/cms',
  ]
  exec {"fetch_cms":
    command => shellquote($fetch_cms_cmd),
    require => Class["adblockplus::git"],
    timeout => 0,
    creates => $cms_vcs_creates,
  }
  $update_cms_cmd = [
    'git',
    '-C', '/opt/cms',
    'pull', '--quiet',
  ]
  cron {'update_cms':
    ensure => present,
    command => shellquote($update_cms_cmd),
    minute  => '4-59/20',
  }

  user {'www':
    ensure => present,
    comment => 'Web content owner',
    home => '/home/www',
    managehome => true,
  }

  Exec {
    path => ["/usr/bin/", "/bin/"],
  }

  if $vcs == "hg" {
    $vcs_class = 'adblockplus::mercurial'
    $repo_vcs_creates = "/home/www/${repository}/.hg/hgrc"
    $fetch_repo_cmd = [
      'hg', 'clone', '--update', 'master',
      hiera('web::server::remote', "https://hg.adblockplus.org/${repository}"),
      "/home/www/${repository}",
    ]
    $update_repo_cmd = [
      'hg', 'pull',
      '--quiet',
      '--rev', 'master',
      '--update',
      '--repository', "/home/www/${repository}",
    ]
  } else {
    $vcs_class = 'adblockplus::git'
    $repo_vcs_creates = "/home/www/${repository}/.git/config"
    $fetch_repo_cmd = [
      'git', 'clone',
      hiera('web::server::remote', "https://gitlab.com/eyeo/websites/${repository}"),
      "/home/www/${repository}",
    ]
    $update_repo_cmd = [
      'git',
      '-C', "/home/www/${repository}",
      'pull', '--quiet',
    ]
  }

  exec {"fetch_repo":
    command => shellquote($fetch_repo_cmd),
    require => Class[$vcs_class],
    user => www,
    timeout => 0,
    creates => $repo_vcs_creates,
  }

  $initialize_content_exec = [
    'python', '-m', 'cms.bin.generate_static_pages',
    "/home/www/${repository}", "/var/www/${vhost}",
  ]

  exec {"initialize_content":
    command => shellquote($initialize_content_exec),
    user => www,
    subscribe => [Exec["fetch_repo"], Exec["fetch_cms"]],
    refreshonly => true,
    environment => $pythonpath,
  }

  file {[
    "/var/cache/$repository",
    "/var/www/$vhost",
    "/var/www/docs",
  ]:
    ensure => directory,
    owner => www,
    mode => '0755',
  }


  $update_webpage_cmd = join(
    [
      shellquote($update_repo_cmd),
      shellquote($initialize_content_exec)
    ],
    "&&"
  )

  cron {'update_repo':
    ensure => present,
    command => $update_webpage_cmd,
    user => www,
    minute  => '5-59/20',
  }

}
