# == Type: buildbot::master
#
# Manage Buildbot (http://buildbot.net/) master instances.
#
# Note that each instance implies the creation of a virtual Concat and
# a virtual Concat::Fragment resource for setting up the master.cfg file.
# One may either realize these resources (as done so by master::fragment
# implicitly, for example) or use a custom approach for setting up the
# configuration.
#
# === Parameters:
#
# [*basedir*]
#   The base directory of the master, which can be configured elsewhere or,
#   if its ancestors are present, relied upon the builtin defaults.
#
# [*database*]
#   Translates directly into the BuildmasterConfig['db_url'] configuration
#   option within the master.cfg file.
#
# [*ensure*]
#   Whether to set up the master (anything but 'absent' or 'purged') or
#   remove the associated resources. Note that only 'purged' implies the
#   removal of $basedir.
#
# [*http_port*]
#   Translates directly into the port portion of the BuildmasterConfig's
#   'buildbotURL', but may be used in other places as well.
#
# [*config*]
#   A hash to use for initalizing the BuildmasterConfig ("c") within the
#   master.cfg file. Can be used to customize "title"/"titleURL" and the
#   "buildbotURL", for example.
#
# [*slaves*]
#   Local buildbot::slave records to set up with the master.
#
# [*slave_credentials*]
#   Name => password pairs of e.g. remote build slaves.
#
# [*slave_port*]
#   Translates directly into the BuildmasterConfig['slavePortnum'] option
#   within the master.cfg file.
#
# [*system*]
#   Any value beside 'false' will cause the master operations to also
#   affect the buildbot::buildmaster service. Use this option to include
#   the master instance with the system daemon.
#
# [*user*]
#   The user to whom the master instance belongs to. Note that the user
#   is not created implicitly by this setup, except if the creation is
#   implied with any of the $buildbot::master_packages.
#
# === Examples:
#
#   buildbot::master {'primary':
#     basedir => '/var/primary-buildmaster',
#     config => {'title' => 'Awesomeness'},
#   }
#
#   buildbot::master {'secondary':
#     basedir => '/var/secondary-buildmaster',
#     ensure => absent,
#   }
#
define buildbot::master (
  $basedir = "$::buildbot::master_directory/$name",
  $database = "sqlite:///state.sqlite",
  $ensure = 'present',
  $http_port = 8010,
  $config = {},
  $slaves = {},
  $slave_credentials = {},
  $slave_port = 9989,
  $system = false,
  $user = $::buildbot::master_user,
) {

  if $ensure !~ /^(absent|purged)$/ {
    ensure_packages($::buildbot::master_packages)
    realize(File[$::buildbot::master_directory])

    exec {"buildmaster#$title":
      command => shellquote([
        $::buildbot::master_runner,
        'create-master',
        $basedir,
      ]),
      creates => "$basedir/buildbot.tac",
      require => [
        File[$::buildbot::master_directory],
        Package[$::buildbot::master_packages],
      ],
      user => $user,
    }

    Exec["buildmaster#$title"] <- Exec <|creates == $basedir|>
    Exec["buildmaster#$title"] <- File <|path == $basedir|>

    $config_file = "$basedir/master.cfg"

    @concat {$config_file:
      owner => $user,
      require => Exec["buildmaster#$title"],
    }

    @concat::fragment {$config_file:
      content => template('buildbot/master.cfg.erb'),
      target => $config_file,
    }

    if !empty($slaves) {
      create_resources('buildbot::slave', $slaves)
      realize(Concat[$config_file])
      realize(Concat::Fragment[$config_file])
    }
  }

  if $system != false {
    ensure_packages($::buildbot::master_packages)
    realize(Concat['buildmaster'])
    realize(Concat::Fragment['buildmaster'])
    realize(Service['buildmaster'])

    concat::fragment {"buildmaster#$title":
      content => template('buildbot/buildmaster_fragment.erb'),
      ensure => $ensure ? {'present' => $ensure, default => 'absent'},
      notify => Service['buildmaster'],
      order => 1,
      target => 'buildmaster',
    }

    Service['buildmaster'] <~ Exec <|creates == "$basedir"|>
    Service['buildmaster'] <~ Exec <|creates == "$basedir/buildbot.tac"|>
    Service['buildmaster'] <~ Exec <|creates == "$basedir/master.cfg"|>

    Service['buildmaster'] <~ File <|path == "$basedir"|>
    Service['buildmaster'] <~ File <|path == "$basedir/master.cfg"|>
  }

  if $ensure == 'purged' {
    file {$basedir: ensure => 'absent'}
  }
}
