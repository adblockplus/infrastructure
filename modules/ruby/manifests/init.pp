# == Class: ruby
#
# Perform a custom Ruby installation based on the ruby-install script,
# using /usr/local as installation prefix.
#
# === Parameters:
#
# [*version*]
#   The Ruby version to build and install.
#
# [*logoutput*]
#   Whether and when to log the output of Exec resources; see
#   https://docs.puppetlabs.com/references/latest/type.html#exec-attribute-logoutput
#
# === Examples:
#
#   class {'ruby':
#     version => '2.2.0',
#     logoutput => true,
#   }
#
class ruby(
  $version = '2.1.5',
  $logoutput = 'on_failure',
) {

  $install_src_url = 'https://github.com/postmodern/ruby-install.git'
  $install_src_dir = '/root/ruby-install'
  $install_command = "$install_src_dir/bin/ruby-install"

  Exec {
    logoutput => true,
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if !defined(Package['git']) {

    package {'git':
      ensure => 'installed',
    }
  }

  exec {'ruby-clone-ruby-install':
    command => shellquote('git', 'clone', $install_src_url, $install_src_dir),
    creates => $install_src_dir,
    logoutput => $logoutput,
    require => Package['git'],
  }
  ->
  exec {'ruby-execute-ruby-install':
    command => shellquote($install_command, '--system', 'ruby', $version),
    creates => '/usr/local/bin/ruby',
    logoutput => $logoutput,
  }
}
