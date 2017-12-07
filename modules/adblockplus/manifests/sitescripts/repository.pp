define adblockplus::sitescripts::repository (
  $location = "/opt/$name",
  $source = "https://hg.adblockplus.org/$name",
) {

  ensure_packages([
    'python',
    'python-flup',
  ])

  $ensure_dependencies_command = shellquote([
    'python', '--', "$location/ensure_dependencies.py", '-q'
  ])

  $fetch_command = join([
    shellquote(['hg', 'clone', $source, $location]),
    $ensure_dependencies_command,
  ], ' && ')

  exec { "fetch_$name":
    command => shellquote(['hg', 'clone', $source, $location]),
    creates => $location,
    path => ['/usr/bin/', '/bin/'],
    require => Package['mercurial'],
  }

  Exec["fetch_$name"] <- Package['mercurial']
  Exec["fetch_$name"] <- Package['python']

  $update_command = join([
    shellquote(['hg', 'pull', '-q', '-u', '-R', $location]),
    $ensure_dependencies_command,
  ], ' && ')

  cron {"update_$name":
    ensure => 'present',
    command => $update_command,
    environment => hiera('cron::environment', []),
    user => 'root',
    minute => [15],
  }

  Cron["update_$name"] <- Exec["fetch_$name"]
}
