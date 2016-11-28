Cron {
  environment => hiera('cron::environment', []),
}

Exec {
  logoutput => 'on_failure',
}

File {
  group => 'root',
}

import 'nodes.pp'
