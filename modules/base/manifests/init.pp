class base {
  stage {'pre': before => Stage['main']}
  class {'apt':
    stage => 'pre',
    always_apt_update => true
  }

  package {['mercurial', 'emacs', 'postfix']: ensure => present}
}
