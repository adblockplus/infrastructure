class users {
  define user (
    $user_name = $title,
    $authorized_keys,
    $password = undef,
    $sudo = false
  ) {
    user {$user_name:
      home => "/home/${user_name}",
      managehome => true,
      groups => $sudo ? {
        true => 'sudo',
        default => undef
      }
    }

    file {"/home/${user_name}/.ssh":
      ensure => directory,
      owner => $user_name,
      mode => 0700,
      require => User[$user_name]
    }

    file {"/home/${user_name}/.ssh/authorized_keys":
      ensure => present,
      owner => $user_name,
      content => $authorized_keys
    }
  }

  file {'/etc/sudoers.d/puppet':
    ensure => present,
    owner => root,
    group => root,
    mode => 0440,
    source => 'puppet:///modules/users/sudoers-puppet'
  }
}

