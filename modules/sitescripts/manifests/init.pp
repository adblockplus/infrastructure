class sitescripts (
    $sitescriptsini_source = '',
    $sitescriptsini_content = '',
  ){

  concat {'/etc/sitescripts.ini':
    mode => 644,
    owner => root,
    group => root,
  }

  define configfragment($content = '', $source = '')
  {
    concat::fragment {"/etc/sitescripts.ini#$title":
      target  => '/etc/sitescripts.ini',
      content => $content,
      source  => "$source$content" ? {
        ''     => $title,
        default => $source,
      }
    }
  }

  configfragment {'/etc/sitescripts.ini':
    content => $sitescriptsini_content,
    source => $sitescriptsini_source,
  }

  exec { "fetch_sitescripts":
    command => "hg clone https://hg.adblockplus.org/sitescripts /opt/sitescripts",
    path => ["/usr/bin/", "/bin/"],
    require => Package['mercurial'],
    onlyif => "test ! -d /opt/sitescripts"
  }

  cron {"update_sitescripts":
    ensure => present,
    command => "hg pull -q -u -R /opt/sitescripts",
    environment => ['MAILTO=admins@adblockplus.org,root'],
    user => root,
    require => Exec["fetch_sitescripts"],
  }
}
