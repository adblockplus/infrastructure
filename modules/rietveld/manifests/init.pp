class rietveld(
    $domain,
    $certificate,
    $private_key,
    $is_default = false,
    $secret_key = hiera('rietveld::secret_key', ''),
    $admins = hiera('rietveld::admins', []),
    $oauth2_client_id = hiera('rietveld::oauth2_client_id', ''),
    $oauth2_client_secret = hiera('rietveld::oauth2_client_secret', ''),
) {

  include nginx
  $rietveld_home = '/opt/rietveld'
  $rietveld_branch = 'default'
  $rietveld_revision = '2259be9bd074'
  $rietveld_source = 'https://hg.adblockplus.org/rietveld'

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  }

  nginx::hostconfig {$domain:
    source => 'puppet:///modules/rietveld/site.conf',
    is_default => $is_default,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_codereview'
  }

  package {['wget', 'unzip', 'make', 'patch', 'subversion']: ensure => present}

  user {'rietveld':
    ensure => present,
    comment => 'User of the rietveld installation',
    home => '/home/rietveld',
    managehome => true
  }

  exec {'download_appengine':
    # TODO: We cannot rely on this URL to stay fixed
    command => 'wget -O /home/rietveld/google_appengine.zip https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.21.zip',
    user => 'root',
    creates => '/home/rietveld/google_appengine.zip',
    require => [User['rietveld'], Package['wget']],
  }

  exec {'install_appengine':
    command => 'unzip /home/rietveld/google_appengine.zip -d /opt',
    user => 'root',
    creates => '/opt/google_appengine',
    require => [Exec['download_appengine'], Package['unzip']],
  }

  exec {'get_rietveld':
    command => shellquote(
      'hg', 'clone', $rietveld_source, '-b', $rietveld_branch,
      '-r', $rietveld_revision, $rietveld_home),
    user => 'root',
    require => Package['mercurial'],
    creates => $rietveld_home,
  }

  exec {'setup_rietveld':
    command => 'make update_revision mapreduce',
    cwd => $rietveld_home,
    user => root,
    require => [Exec['get_rietveld'], Package['make', 'patch', 'subversion']],
    creates => "${rietveld_home}/mapreduce",
  }

  file {'/opt/wrappers':
    ensure => directory,
    owner => 'root',
  }

  file {'wrapper.py':
    path => '/opt/wrappers/wrapper.py',
    ensure => file,
    owner => 'root',
    mode => '0755',
    source => 'puppet:///modules/rietveld/wrapper.py',
    notify => Service['rietveld'],
  }

  file {'dev_appserver.py':
    path => '/opt/wrappers/dev_appserver.py',
    ensure => link,
    require => File['wrapper.py'],
    target => '/opt/wrappers/wrapper.py',
  }

  file {'_python_runtime.py':
    path => '/opt/wrappers/_python_runtime.py',
    ensure => link,
    require => File['wrapper.py'],
    target => '/opt/wrappers/wrapper.py',
  }

  file {'/var/lib/rietveld':
    ensure => directory,
    owner => 'rietveld',
  }

  file {'config.ini':
    path => '/var/lib/rietveld/config.ini',
    ensure => file,
    owner => 'root',
    content => template('rietveld/config.ini.erb'),
    notify => Service['rietveld'],
  }

  customservice {'rietveld':
    command => "/opt/wrappers/dev_appserver.py \
      --enable_sendmail --skip_sdk_update_check
      --port 8080 ${rietveld_home}",
    user => 'rietveld',
    require => [
      Exec['install_appengine', 'setup_rietveld'],
      File['dev_appserver.py', '_python_runtime.py', 'config.ini'],
    ],
  }
}
