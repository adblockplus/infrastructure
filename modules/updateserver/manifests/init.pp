class updateserver(
    $domain,
    $certificate,
    $private_key,
    $is_default=false
  ) {
  class {'nginx':
    worker_connections => 4000,
    ssl_session_cache => off,
  }

  File {
    owner => root,
    group => root
  }

  file {'/var/www':
    ensure => directory,
    mode => '0755',
    require => Package['nginx']
  }

  $update_dir = '/var/www/update'

  file {$update_dir:
    ensure => directory,
    mode => '0755',
  }

  $sitescripts_var_dir = '/var/lib/sitescripts'

  user {'sitescripts':
    ensure => present,
    home => $sitescripts_var_dir
  }

  file {$sitescripts_var_dir:
    ensure => directory,
    mode => '0755',
    owner => 'sitescripts',
    group => 'sitescripts'
  }

  $update_manifest_dirs = ["${update_dir}/gecko",
                           "${update_dir}/adblockplusandroid",
                           "${update_dir}/adblockplusie",
                           "${update_dir}/adblockplussafari"]

  file {$update_manifest_dirs:
    ensure => directory,
    mode => '0755',
    owner => 'sitescripts',
    group => 'sitescripts'
  }

  nginx::hostconfig{$domain:
    source => 'puppet:///modules/updateserver/site.conf',
    is_default => $is_default,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_update'
  }

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/updateserver/sitescripts'
  }

  $safari_certificate_path = "${sitescripts_var_dir}/adblockplussafari.pem"

  file {$safari_certificate_path:
    source => 'puppet:///modules/private/adblockplussafari.pem'
  }

  $repositories_to_sync = ['downloads', 'adblockplus', 'adblockplusandroid',
                           'adblockpluschrome', 'adblockplusie',
                           'elemhidehelper', 'abpwatcher', 'abpcustomization',
                           'urlfixer']

  define fetch_repository() {
    $repository_path = "${updateserver::sitescripts_var_dir}/${title}"
    exec {"fetch_repository_${title}":
      command => "hg clone -U https://hg.adblockplus.org/${title} ${repository_path}",
      path => '/usr/local/bin:/usr/bin:/bin',
      user => 'sitescripts',
      timeout => 0,
      onlyif => "test ! -d ${repository_path}",
      require => [Package['mercurial'], File[$updateserver::sitescripts_var_dir]]
    }
  }

  fetch_repository {$repositories_to_sync: }

  $update_update_manifests_script = '/usr/local/bin/update_update_manifests'

  file {$update_update_manifests_script:
    mode => '0755',
    content => template('updateserver/update_update_manifests.erb')
  }

  ensure_packages(['python-pip', 'python-dev'])

  # Make sure that apt packages corresponding to the pip-installed modules below
  # won't be installed unintentionally, these will take precedence otherwise.
  package {['python-jinja2', 'python-crypto']:
    ensure => 'held',
  }

  package {'Jinja2':
    ensure => '2.8',
    provider => 'pip',
    require => [Package['python-pip'], Package['python-jinja2']],
  }

  package {'pycrypto':
    ensure => '2.6.1',
    provider => 'pip',
    require => [Package['python-pip'], Package['python-crypto'], Package['python-dev']],
  }

  exec {'update_update_manifests':
    command => $update_update_manifests_script,
    user => 'sitescripts',
    timeout => 0,
    require => [Class['sitescripts'],
                Fetch_repository[$repositories_to_sync],
                File[$update_update_manifests_script],
                File[$update_manifest_dirs], File[$safari_certificate_path],
                Package['Jinja2', 'pycrypto']]
  }

  cron {'update_update_manifests':
    ensure => present,
    command => $update_update_manifests_script,
    user => 'sitescripts',
    minute => '*/10',
    require => Exec['update_update_manifests']
  }

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
