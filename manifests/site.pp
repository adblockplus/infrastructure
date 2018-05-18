include adblockplus::legacy

Cron {
  environment => hiera('cron::environment', []),
}

Exec {
  logoutput => 'on_failure',
}

File {
  group => 'root',
}

# Class['apt'] cannot yet be configured to update on-demand
class {'apt':
  always_apt_update => ($environment != 'development'),
}

