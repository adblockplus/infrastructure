Cron {
  environment => 'MAILTO=admins@adblockplus.org'
}

Exec {
  logoutput => 'on_failure',
}

import 'nodes.pp'
