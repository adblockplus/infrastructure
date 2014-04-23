class statsmaster::downloads {
  package {['pypy', 'python-jinja2']:}

  class {'sitescripts':
    sitescriptsini_source => 'puppet:///modules/statsmaster/sitescripts.ini',
  }

  file {'/var/www/stats':
    ensure => directory,
    mode => 0755,
    owner => stats,
  }

  file {'/var/www/statsdata':
    ensure => directory,
    mode => 0755,
    owner => stats,
  }

  file {'/var/www/statsdata/usercounts.html':
    ensure => file,
    mode => 0444,
    source => 'puppet:///modules/statsmaster/usercounts.html',
    owner => stats,
  }

  cron {'updatestats':
    ensure => present,
    require => [
                 Package['pypy'],
                 Package['python-jinja2'],
                 Exec["fetch_sitescripts"]
               ],
    command => "pypy -m sitescripts.stats.bin.logprocessor && python -m sitescripts.stats.bin.pagegenerator",
    environment => ['MAILTO=admins@adblockplus.org,root', 'PYTHONPATH=/opt/sitescripts'],
    user => stats,
    hour => 1,
    minute => 30,
  }
}
