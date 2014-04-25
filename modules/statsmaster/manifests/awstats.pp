class statsmaster::awstats {

  include private::global

  package {['awstats', 'libgeo-ip-perl']:}

  file {'/var/www/awstatsdata':
    ensure => directory,
    owner => root,
    mode => 0755,
  }

  file {'/var/www/awstatsconf':
    ensure => directory,
    owner => root,
    mode => 0755,
  }

  file {'/var/www/awstats':
    ensure => directory,
    owner => root,
    mode => 0755,
  }

  file {'/var/www/awstats/archive':
    ensure => directory,
    owner => root,
    mode => 0755,
  }

  concat {'/var/www/awstats/index.html':
    mode => 0644,
    owner => root,
  }

  concat {'/home/stats/process_logs':
    owner => stats,
    mode => 0700,
  }

  concat {'/home/stats/build_static':
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

  define siteconfig($host, $log) {
    file {"/var/www/awstatsconf/awstats.$title.conf":
      ensure => present,
      mode => 0444,
      owner => root,
      content => template('statsmaster/awstats.conf'),
    }

    file {["/var/www/awstatsdata/$title", "/var/www/awstats/$title", "/var/www/awstats/archive/$title"]:
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
  }

  $sites = {
    'adblockplus.org' => {
      host => 'ssh.adblockplus.org',
      log => 'access_log_adblockplus',
    },
    'easylist.adblockplus.org' => {
      host => 'ssh.adblockplus.org',
      log => 'access_log_easylist',
    },
    'share.adblockplus.org' => {
      host => 'ssh.adblockplus.org',
      log => 'access_log_share',
    },
    'facebook.adblockplus.me' => {
      host => 'ssh.adblockplus.org',
      log => 'access_log_facebook',
    },
    'youtube.adblockplus.me' => {
      host => 'ssh.adblockplus.org',
      log => 'access_log_youtube',
    },
    'acceptableads.org' => {
      host => 'ssh.adblockplus.org',
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

  cron {'awstats_update':
    ensure => present,
    require => [
      Package['awstats', 'libgeo-ip-perl'],
      Concat['/home/stats/process_logs'],
      Concat['/home/stats/build_static'],
      File['/var/www/awstatsconf'],
      File['/var/www/awstatsdata'],
      File['/var/www/awstats'],
    ],
    command => '/home/stats/process_logs && /home/stats/build_static',
    environment => ["MAILTO=$private::global::admin_mail,root"],
    user => stats,
    hour => 4,
    minute => 0,
  }

  cron {'awstats_prevmonth':
    ensure => present,
    require => [
      Package['awstats'],
      Concat['/home/stats/build_static'],
      File['/var/www/awstatsconf'],
      File['/var/www/awstatsdata'],
      File['/var/www/awstats/archive'],
    ],
    command => '/home/stats/build_static prevmonth',
    environment => ["MAILTO=$private::global::admin_mail,root"],
    user => stats,
    monthday => 1,
    hour => 6,
    minute => 0,
  }
}
