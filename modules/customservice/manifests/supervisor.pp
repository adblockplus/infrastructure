# == Type: customservice::supervisor
#
# Periodically check for and revive dead service processes.
#
# === Parameters:
#
# [*ensure*]
#   Whether to ensure the service record being 'present' or not within
#   the list of services recognized by the supervisor.
#
# [*name*]
#   The $name of the service, matching it's name in the init system, i.e.
#   the init-script's basename. Defaults to $title.
#
# [*pidfile*]
#   The path to the process ID file associated with the service, if present.
#
# === Examples:
#
#   customservice::supervisor {'example':
#     name => 'sshd',
#     ensure => 'present',
#   }
#
#   customservice::supervisor {'spawn-fcgi':
#     pidfile => '/var/run/500-example_spawn-fcgi.pid',
#   }
#
define customservice::supervisor (
  $ensure = 'present',
  $pidfile = "/var/run/$name.pid"
) {

  include sitescripts

  $config = '/etc/customservice_supervisor.ini'
  $module = 'sitescripts.management.bin.start_services'
  $target = 'customservice::supervisor'

  ensure_resource('concat', $target, {
    path => $config,
  })

  ensure_resource('concat::fragment', $target, {
    content => "[keep_alive_services]\n",
    order => 0,
    target => $target,
  })

  ensure_resource('cron', $target, {
    command => "SITESCRIPTS_CONFIG=$config python -m $module",
    environment => concat(hiera('cron::environment', []), [
      'PYTHONPATH=/opt/sitescripts',
    ]),
    require => [
      Class['sitescripts'],
      Concat::Fragment[$target],
    ],
  })

  concat::fragment {"$target#$name":
    content => "$name = $pidfile\n",
    ensure => $ensure ? {
      /^(absent|purged)$/ => 'absent',
      default => 'present',
    },
    order => 1,
    target => $target,
  }
}
