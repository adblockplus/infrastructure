class base {
  package {'emacs': ensure => present}

  package {'mercurial': ensure => present}
  if $operatingsystem == 'OpenSuSE' {
    package {'patterns-openSUSE-minimal_base-conflicts': ensure => absent}
    Package['patterns-openSUSE-minimal_base-conflicts'] -> Package['mercurial']
  }
}
