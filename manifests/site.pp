Cron {
  environment => 'MAILTO=admins@adblockplus.org'
}

import 'webserver.pp'
import 'filterserver.pp'
import 'monitoringserver.pp'
