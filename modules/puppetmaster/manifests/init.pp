class puppetmaster {
  file {'/etc/sudoers.d/update-infrastructure':
    ensure => present,
    owner => root,
    group => root,
    mode => 0440,
    source => 'puppet:///modules/puppetmaster/sudoers-update-infrastructure'
  }
}
