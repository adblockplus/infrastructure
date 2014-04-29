include private::global

Cron {
  environment => "MAILTO=$private::global::admin_mail"
}

import 'nodes.pp'
