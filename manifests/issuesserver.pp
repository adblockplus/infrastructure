node 'issues1' {

  include private::trac

  class {'trac':
    domain => 'issues.adblockplus.org',
    certificate => 'issues.adblockplus.org_sslcert.pem',
    private_key => 'issues.adblockplus.org_sslcert.key',
    is_default => true,
  }

  trac::instance {'issues':
    config => 'trac/trac.ini.erb',
    description => 'Adblock Plus Issue Tracker',
    location => '/',
    logo => 'puppet:///modules/trac/adblockplus_logo.png',
    database => 'trac',
    permissions => "puppet:///modules/trac/permissions.csv",
  }

  trac::instance {'orders':
    config => 'trac/orders.ini.erb',
    description => 'Eyeo Order System',
    location => '/orders',
    logo => 'puppet:///modules/trac/eyeo_logo.png',
    database => 'trac_orders',
    permissions => "puppet:///modules/trac/order-permissions.csv",
  }

  # Transforming the auth_cookie table of the "new" Trac project into an
  # insertable view for the "old" project's table of the same name avoids
  # the need to convert the entire auth to htpasswd-file handling, which
  # would be the official way to go for achieving a shared authentication.
  exec { 'trac_auth_cookie_view':
    command => "mysql -utrac -p'${private::trac::database_password}' trac_orders --execute '
      DROP TABLE IF EXISTS auth_cookie;
      CREATE VIEW auth_cookie AS SELECT * FROM trac.auth_cookie;'",
    unless => "mysql -utrac -p'${private::trac::database_password}' trac_orders --execute '
      SHOW CREATE VIEW auth_cookie'",
    path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
    require => [
      Exec["deploy_issues"],
      Exec["deploy_orders"],
    ],
  }

  $mysql = "mysql -utrac -p'${private::trac::database_password}'"

  # Synchronizing e-mail and password information between the project
  # allows for logging in from any entry point - whilst maintaining a
  # registration form (and process) in one project only.
  cron {'trac_session_attribute_sync':
    ensure => present,
    user => trac,
    minute => '*/30',
    command => "$mysql trac_orders --execute ' \
      INSERT INTO session_attribute (sid, authenticated, name, value) SELECT sid, authenticated, name, value \
      FROM trac.session_attribute WHERE authenticated = 1 AND name IN (\"email\", \"password\") \
      ON DUPLICATE KEY UPDATE value=VALUES(value) ' >/dev/null
    ",
    require => Exec['trac_auth_cookie_view'],
  }

  cron {'trac_session_cleanup':
    command => "$mysql trac --execute ' \
      DELETE session, session_attribute FROM session \
      JOIN session_attribute ON session.sid = session_attribute.sid \
      AND session.authenticated = session_attribute.authenticated \
      WHERE session.authenticated = 0 AND \
      session.last_visit < UNIX_TIMESTAMP(NOW() - INTERVAL 10 DAY)' >/dev/null",
    ensure => present,
    hour => 1,
    minute => 0,
    require => Trac::Instance['issues'],
    user => trac,
  }

  cron {'trac_account_cleanup':
    command => "$mysql trac --execute ' \
      DELETE session, session_attribute FROM session \
      JOIN session_attribute AS session_data ON session.sid = session_data.sid \
      AND session.authenticated = session_data.authenticated \
      JOIN session_attribute ON session.sid = session_attribute.sid \
      AND session.authenticated = session_attribute.authenticated \
      WHERE session_data.name = \"email_verification_token\" AND \
      session.last_visit < UNIX_TIMESTAMP(NOW() - INTERVAL 5 DAY)' >/dev/null",
    ensure => present,
    hour => 2,
    minute => 0,
    require => Trac::Instance['issues'],
    user => trac,
  }

  # https://issues.adblockplus.org/ticket/3787
  customservice::supervisor {"spawn-fcgi":
    ensure => 'present',
    pidfile => "/var/run/500-tracd_issues_spawn-fcgi.pid",
  }
}
