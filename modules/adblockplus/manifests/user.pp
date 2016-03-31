# == Type: adblockplus::user
#
# Manage user accounts.
#
# === Parameters:
#
# [*authorized_keys*]
#   A list of zero or more lines for the ~/.ssh/authorized_keys file of
#   the respective user. Used as-is, joined by newline characters.
#
# [*groups*]
#   A list of zero or more groups (names), to assign the user to.
#
# [*name*]
#   The name of the user account, defaults to $title.
#
# [*password_hash*]
#   The user's password, as lexical SHA1 hashsum. If undefined, Puppet
#   won't change the current one, if any. Use "*" to disable the user's
#   password explicitly.
#
# === Examples:
#
#   adblockplus::user {'pinocchio':
#     authorized_keys => [
#       'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAA..................',
#       'from="10.0.8.2" ssh-rsa AAAAB3NzaC..................',
#     ],
#     groups => ['sudo', 'adm'],
#     password_hash => '$6$k.fe9F4U$OIav.SJ..................',
#   }
#
define adblockplus::user (
  $authorized_keys = [],
  $ensure = 'present',
  $groups = [],
  $password_hash = undef,
) {

  include adblockplus

  # Re-used multiple times below
  $home = "/home/$name"

  user {$name:
    ensure => $ensure,
    groups => $groups,
    home => $home,
    managehome => true,
    password => $password_hash,
    shell => '/bin/bash',
  }

  file {"$home/.ssh":
    ensure => $ensure ? {
      'present' => 'directory',
      default => $ensure,
    },
    mode => 0700,
    owner => $name,
    require => User[$name],
  }

  file {"$home/.ssh/authorized_keys":
    content => join($authorized_keys, "\n"),
    ensure => $ensure,
    mode => 0644,
    owner => $name,
    require => File["$home/.ssh"],
  }
}
