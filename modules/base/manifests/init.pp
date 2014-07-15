class base {
  stage {'pre': before => Stage['main']}
  stage {'post': require => Stage['main']}

  class {'users':
    stage => 'pre',
  }

  class {'apt':
    always_apt_update => true
  }

  Exec['apt_update'] -> Package <| |>

  include private::users, postfix, ssh

  package {['mercurial', 'vim', 'emacs', 'debian-goodies']: ensure => present}

  file {'/etc/timezone':
    ensure => file,
    owner => root,
    group => root,
    mode => 0644,
    content => 'UTC',
    notify => Service['cron']
  }

  file {'/etc/localtime':
    ensure => link,
    target => '/usr/share/zoneinfo/UTC',
    notify => Service['cron']
  }

  service {'cron':
    ensure => running,
    enable => true,
  }

  class {'logrotate':
    stage => 'post'
  }
}
