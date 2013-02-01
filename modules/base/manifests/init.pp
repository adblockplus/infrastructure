class base {
  stage {'pre': before => Stage['main']}
  class {'apt':
    stage => 'pre',
    always_apt_update => true
  }

  package {['mercurial', 'emacs', 'postfix']: ensure => present}

  file {'/etc/timezone':
    ensure => file,
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/base/timezone'
  }
}
