class hosts($hosts) {
  file {'/etc/hosts':
    mode => 644,
    owner => root,
    group => root,
    content => template('hosts/hosts.erb')
  }
}
