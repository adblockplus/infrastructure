class statsmaster::awstats {
  package {['awstats', 'libgeo-ip-perl']:}

  file {['/var/www/awstatsdata', '/var/www/awstatsdatadaily',
      '/var/www/awstatsconf', '/var/www/awstats',
      '/var/www/awstats/archive', '/var/www/awstats/daily']:
    ensure => directory,
    owner => root,
    mode => 0755,
  }

  file {'/etc/cron.d/awstats':
    # AWStats package thinks that running AWStats without proper configuration
    # every 10 minutes is a good idea.
    ensure => absent,
  }

  concat {'/var/www/awstats/index.html':
    mode => 0644,
    owner => root,
  }

  concat {['/home/stats/process_logs', '/home/stats/build_static',
      '/home/stats/anonymize_ips']:
    owner => stats,
    mode => 0700,
  }

  concat::fragment {'index_head':
    target => '/var/www/awstats/index.html',
    content => template('statsmaster/index_head.html.erb'),
    order => 'aaahead',
  }

  concat::fragment {'index_foot':
    target => '/var/www/awstats/index.html',
    content => template('statsmaster/index_foot.html.erb'),
    order => 'zzzfoot',
  }

  concat::fragment {'process_logs_head':
    target => '/home/stats/process_logs',
    content => template('statsmaster/process_logs_head.erb'),
    order => 'aaahead',
  }

  concat::fragment {'build_static_head':
    target => '/home/stats/build_static',
    content => template('statsmaster/build_static_head.erb'),
    order => 'aaahead',
  }

  concat::fragment {'anonymize_ips_head':
    target => '/home/stats/anonymize_ips',
    content => template('statsmaster/anonymize_ips_head.erb'),
    order => 'aaahead',
  }

  define siteconfig($host, $log) {
    file {"/var/www/awstatsconf/awstats.$title.conf":
      ensure => present,
      mode => 0444,
      owner => root,
      content => template('statsmaster/awstats.conf'),
    }

    file {["/var/www/awstatsdata/$title", "/var/www/awstatsdatadaily/$title",
        "/var/www/awstats/$title", "/var/www/awstats/archive/$title",
        "/var/www/awstats/daily/$title"]:
      ensure => directory,
      mode => 0755,
      owner => stats,
    }

    concat::fragment {"index_$title":
      target => '/var/www/awstats/index.html',
      content => template('statsmaster/index_item.html.erb'),
      order => $title,
    }

    concat::fragment {"process_logs_$title":
      target => '/home/stats/process_logs',
      content => template('statsmaster/process_logs_item.erb'),
      order => $title,
    }

    concat::fragment {"build_static_$title":
      target => '/home/stats/build_static',
      content => template('statsmaster/build_static_item.erb'),
      order => $title,
    }

    concat::fragment {"anonymize_ips_$title":
      target => '/home/stats/anonymize_ips',
      content => template('statsmaster/anonymize_ips_item.erb'),
      order => $title,
    }
  }

  $sites = {
    'adblockplus.org' => {
      host => 'web2.adblockplus.org',
      log => 'access_log_adblockplus',
    },
    'easylist.adblockplus.org' => {
      host => 'ssh.adblockplus.org',
      log => 'access_log_easylist',
    },
    'share.adblockplus.org' => {
      host => 'web-sh-abp-org-1.adblockplus.org',
      log => 'access_log_share',
    },
    'facebook.adblockplus.me' => {
      host => 'web-fb-abp-me-1.adblockplus.org',
      log => 'access_log_facebook',
    },
    'youtube.adblockplus.me' => {
      host => 'web-yt-abp-me-1.adblockplus.org',
      log => 'access_log_youtube',
    },
    'acceptableads.org' => {
      host => 'web-aa-org-1.adblockplus.org',
      log => 'access_log_acceptableads',
    },
    'eyeo.com' => {
      host => 'web1.adblockplus.org',
      log => 'access_log_eyeo.com',
    },
    'intraforum.adblockplus.org' => {
      host => 'server_10.adblockplus.org',
      log => 'access_log_intraforum',
    },
  }

  create_resources(statsmaster::awstats::siteconfig, $sites)

  #
  # IMPORTANT: This will only work correctly if the following bugs are fixed
  # in your AWStats instance (might require manual patching):
  #
  # * https://sourceforge.net/p/awstats/bugs/873/
  # * https://sourceforge.net/p/awstats/bugs/929/
  #

  cron {'awstats_update':
    ensure => present,
    require => [
      Package['awstats', 'libgeo-ip-perl'],
      File['/home/stats/process_logs', '/home/stats/build_static',
        '/var/www/awstatsdata', '/var/www/awstatsdatadaily',
        '/var/www/awstats', '/var/www/awstatsconf'],
    ],
    command => '/home/stats/process_logs && /home/stats/build_static',
    environment => ['MAILTO=admins@adblockplus.org,root'],
    user => stats,
    hour => 4,
    minute => 0,
  }

  cron {'awstats_prevmonth':
    ensure => present,
    require => [
      Package['awstats'],
      File['/home/stats/build_static', '/home/stats/anonymize_ips',
        '/var/www/awstatsdata', '/var/www/awstatsdatadaily',
        '/var/www/awstatsconf', '/var/www/awstats'],
    ],
    command => '/home/stats/anonymize_ips prevmonth && /home/stats/build_static prevmonth',
    environment => ['MAILTO=admins@adblockplus.org,root'],
    user => stats,
    monthday => 1,
    hour => 6,
    minute => 0,
  }
}
