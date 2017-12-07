class sitescripts (
    $sitescriptsini_source = '',
    $sitescriptsini_content = '',
  ){

  ensure_resource('adblockplus::sitescripts::repository', 'sitescripts')

  @concat {'/etc/sitescripts.ini':
    mode => '644',
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
}
