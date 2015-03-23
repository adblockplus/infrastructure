class rietveld(
    $domain,
    $certificate,
    $private_key,
    $is_default = false,
    $fixtures = hiera('rietveld::fixtures', {}),
  ) inherits private::rietveld {

  include nginx
  $django_home = '/home/rietveld/django-gae2django'
  $rietveld_home = "${django_home}/examples/rietveld"

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

  package {['python-django', 'make', 'patch', 'gunicorn']: ensure => present}

  user {'rietveld':
    ensure => present,
    comment => 'User of the rietveld installation',
    home => '/home/rietveld',
    managehome => true
  }

  exec {'get_rietveld':
    command => "hg clone https://code.google.com/p/django-gae2django/ ${django_home}/",
    require => Package['mercurial'],
    user => rietveld,
    onlyif => "test ! -d ${django_home}",
  }

  file {"${rietveld_home}/Makefile":
    ensure => file,
    owner => rietveld,
    require => Exec['get_rietveld'],
    source => 'puppet:///modules/rietveld/Makefile',
  }

  file {"${rietveld_home}/settings.py":
    ensure => file,
    owner => rietveld,
    require => Exec['get_rietveld'],
    content => template('rietveld/settings.py.erb'),
  }

  exec {'install_rietveld':
    command => "make all",
    cwd => "${rietveld_home}",
    user => rietveld,
    require => [
      File["${rietveld_home}/Makefile"],
      File["${rietveld_home}/settings.py"]],
    onlyif => "test ! -f ${$rietveld_home}/dev.db",
  }

  file {'/etc/init/rietveld.conf':
    ensure => file,
    owner => root,
    source => 'puppet:///modules/rietveld/rietveld.conf',
    notify => Service['rietveld'],
  }

  file {'/etc/init.d/rietveld':
    ensure => link,
    target => '/lib/init/upstart-job',
    require => [File['/etc/init/rietveld.conf'], Exec['install_rietveld']]
  }

  service {'rietveld':
    ensure => running,
    hasstatus => false,
    require => [Package['gunicorn'], File['/etc/init.d/rietveld']]
  }

  file {"${rietveld_home}/fixtures":
    ensure => directory,
    owner => 'rietveld',
    mode => 0750,
    require => Exec['install_rietveld'],
  }

  define fixture(
    $ensure = present,
    $source = undef,
    $content = undef,
  ) {

    # Note that $script will return EXIT_SUCCESS when the .type is
    # not recognized - although no action is done then. Thus we enforce
    # JSON here, which is the default for command "dumpdata" anyway:
    $script = "${rietveld::rietveld_home}/manage.py"
    $destination = "${rietveld::rietveld_home}/fixtures/$name.json"

    exec {$destination:
      command => shellquote($script, 'loaddata', $destination),
      cwd => $rietveld::rietveld_home,
      refreshonly => true,
      user => 'rietveld',
    }

    file {$destination:
      ensure => $ensure,
      content => $content,
      source => $source,
      owner => 'rietveld',
      mode => 0640,
      notify => $ensure ? {
        present => Exec[$destination],
        default => [],
      }
    }
  }

  create_resources(rietveld::fixture, $fixtures)
}
