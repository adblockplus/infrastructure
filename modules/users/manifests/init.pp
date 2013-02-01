class users {
  define user ($user_name = $title, $authorized_keys, $sudo = false) {
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
      require => User[$user_name]
    }

    file {"/home/${user_name}/.ssh/authorized_keys":
      ensure => present,
      content => $authorized_keys
    }
  }
}
