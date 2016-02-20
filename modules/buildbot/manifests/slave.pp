# == Type: buildbot::slave
#
# Manage Buildbot (http://buildbot.net/) slave instances.
#
# === Parameters:
#
# [*basedir*]
#   The base directory of the slave, which can be configured elsewhere or,
#   if its ancestors are present, relied upon the builtin defaults.
#
# [*ensure*]
#   Whether to set up the slave (anything but 'absent' or 'purged') or
#   remove the associated resources. Note that only 'purged' implies the
#   removal of $basedir.
#
# [*master*]
#   The "$hostname:$port" combination of the build master.
#
# [*name*]
#   The build slave's name.
#
# [*password*]
#   The build slave's password with the master.
#
# [*system*]
#   Any value beside 'false' will cause the slave operations to also
#   affect the buildbot::buildslave service. Use this option to include
#   the slave instance with the system daemon.
#
# [*user*]
#   The user to whom the slave instance belongs to. Note that the user
#   is not created implicitly by this setup, except if the creation is
#   implied with any of the $buildbot::slave_packages.
#
# === Examples:
#
#   buildbot::slave {'alpha':
#     basedir => '/var/buildslave-alpha',
#   }
#
#   buildbot::slave {'beta':
#     ensure => absent,
#   }
#
define buildbot::slave (
  $admin = 'buildbot@localhost',
  $basedir = "$::buildbot::slave_directory/$name",
  $ensure = 'present',
  $master = 'localhost:9989',
  $password = 'changeme',
  $system = false,
  $user = $::buildbot::slave_user,
) {

  if $ensure !~ /^(absent|purged)$/ {
    ensure_packages($::buildbot::slave_packages)
    realize(File[$::buildbot::slave_directory])

    exec {"buildslave#$title":
      command => shellquote([
        $::buildbot::slave_runner,
        'create-slave',
        $basedir,
        $master,
        $name,
        $password,
      ]),
      creates => "$basedir/buildbot.tac",
      require => [
        File[$::buildbot::master_directory],
        Package[$::buildbot::master_packages],
      ],
      user => $user,
    }

    Exec["buildslave#$title"] <- Exec <|creates == $basedir|>
    Exec["buildslave#$title"] <- File <|path == $basedir|>

    file {"$basedir/info/admin":
      content => $admin,
      owner => $user,
      require => Exec["buildslave#$title"],
    }
  }

  if $system != false {
    ensure_packages($::buildbot::slave_packages)
    realize(Concat['buildslave'])
    realize(Concat::Fragment['buildslave'])
    realize(Service['buildslave'])

    concat::fragment {"buildslave#$title":
      content => template('buildbot/buildslave_fragment.erb'),
      ensure => $ensure ? {'present' => $ensure, default => 'absent'},
      notify => Service['buildslave'],
      order => 1,
      target => 'buildslave',
    }

    Service['buildslave'] <~ Exec <|creates == "$basedir"|>
    Service['buildslave'] <~ Exec <|creates == "$basedir/buildbot.tac"|>

    Service['buildslave'] <~ File <|path == "$basedir"|>
    Service['buildslave'] <~ File <|path == "$basedir/info/admin"|>
  }

  if $ensure == 'purged' {
    file {$basedir: ensure => 'absent'}
  }
}
