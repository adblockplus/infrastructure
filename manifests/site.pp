Cron {
  environment => hiera('cron::environment', []),
}

Exec {
  logoutput => 'on_failure',
}

import 'nodes.pp'
