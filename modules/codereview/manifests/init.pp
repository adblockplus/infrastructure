# == Class: codereview
#
# A codereview server setup based on Rietveld and PostgreSQL.
#
# === Parameters:
#
# [*domain*]
#   The auhority part of the URL the Rietveld instance is associated with.
#
# [*is_default*]
#   Whether the $domain shall become set up as default (or fallback)
#   within the HTTP daemon.
#
# [*certificate*]
#   The name of the SSL certificate file within modules/private/files, if
#   any. Requires a private_key as well.
#
# [*private_key*]
#   The name of the private key file within modules/private/files, if any.
#   Requires a certificate as well.
#
# [*database_account*]
#   The name of the database account Rietveld shall use.
#
# [*database_password*]
#   The password identifying Rietveld with the database.
#
# [*database_name*]
#   The name of the Rietveld database within the RDBMS.
#
# === Examples:
#
#   class {'codereview':
#     domain => 'localhost',
#     database_name => 'codereview',
#     database_account => 'codereview',
#     database_password => 'swordfish',
#   }
#
class codereview(
  $domain,
  $is_default = false,
  $certificate = undef,
  $private_key = undef,
  $database_account = hiera('codereview::database_account', 'rietveld'),
  $database_password = hiera('codereview::database_password', 'changeme'),
  $database_name = hiera('codereview::database_name', 'codereview'),
) {

  class {'postgresql::server':
  }

  postgresql::server::database {$database_name:
  }
  ->
  postgresql::server::role {$database_account:
    db => $database_name,
    password_hash => postgresql_password($database_account, $database_password),
    login => true,
    superuser => false,
  }
  ->
  postgresql::server::database_grant {$database_account:
    db => $database_name,
    privilege => 'ALL',
    role => $database_account,
  }

  class {'rietveld':
    domain => $domain,
    certificate => $certificate,
    private_key => $private_key,
    is_default => $is_default,
    database => {
      'engine' => 'postgresql_psycopg2',
      'name' => $database_name,
      'user' => $database_account,
      'password' => $database_password,
    },
  }

  package {['python-psycopg2']:
    ensure => installed,
  }

  Class['rietveld'] <- Package['python-psycopg2']
  Class['rietveld'] <- Postgresql::Server::Database_grant[$database_account]
}

