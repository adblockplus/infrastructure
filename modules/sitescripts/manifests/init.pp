class sitescripts (
    $sitescriptsini_source = '',
    $sitescriptsini_content = '',
  ){

  @concat {'/etc/sitescripts.ini':
    mode => 644,
    owner => root,
    group => root,
  }

  define configfragment($content = '', $source = '') {

    realize(Concat['/etc/sitescripts.ini'])

    concat::fragment {"/etc/sitescripts.ini#$title":
      target  => '/etc/sitescripts.ini',
      content => $content,
      source  => "$source$content" ? {
        ''     => $title,
        default => $source,
      }
    }
  }

  ensure_packages(['python-flup'])

  if ($sitescriptsini_source != '') or ($sitescriptsini_content != '') {

    $content = $sitescriptsini_content
    $source = $sitescriptsini_source
  }
  else {

    $content = "# Puppet: Class['$title']\n"
    $source = ''
  }

  configfragment {'/etc/sitescripts.ini':
    content => $content,
    source => $source,
  }

  $configfragments = hiera('sitescripts::configfragments', {})
  create_resources('sitescripts::configfragment', $configfragments)

  exec { "fetch_sitescripts":
    command => "hg clone https://hg.adblockplus.org/sitescripts /opt/sitescripts",
    path => ["/usr/bin/", "/bin/"],
    require => Package['mercurial'],
    onlyif => "test ! -d /opt/sitescripts"
  }

  cron {"update_sitescripts":
    ensure => present,
    command => "hg pull -q -u -R /opt/sitescripts && /opt/sitescripts/ensure_dependencies.py -q",
    environment => hiera('cron::environment', []),
    user => root,
    require => Exec["fetch_sitescripts"],
    minute => [15, 30, 45],
  }
}
