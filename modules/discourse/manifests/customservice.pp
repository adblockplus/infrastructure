define discourse::customservice(
  $command,
  $user,
  $env = [],
  $workdir = undef
) {
  file {"/etc/init.d/$name":
    ensure => present,
    owner => root,
    group => root,
    mode => '0755',
    content => template('discourse/init-customservice.erb'),
    notify => Service["$name"]
  }

  service {$name:
    ensure => running,
    hasstatus => true,
    enable => true,
    require => File["/etc/init.d/$name"]
  }
}
