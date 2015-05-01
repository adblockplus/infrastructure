# == Class: issuetracker
#
# An issue tracker setup based on Redmine and PostgreSQL.
#
# === Parameters:
#
# None so far.
#
# === Examples:
#
#   class {'issuetracker':
#     database_account => 'redmine',
#     database_password => 'changeme',
#     database_name => 'issues',
#   }
#
class issuetracker(
  $database_account = hiera('issuetracker::database_account', 'redmine'),
  $database_password = hiera('issuetracker::database_password', 'changeme'),
  $database_name = hiera('issuetracker::database_name', 'issuetracker'),
) {

  include base
  include postgresql::server
  include ruby

  # A depenency of Ruby's native GEM for PostgreSQL
  if !defined(Package['postgresql-server-dev']) {

    package {'postgresql-server-dev':
      name => 'postgresql-server-dev-all',
      ensure => 'installed',
    }
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

  class {'redmine':
    database => {
      adapter => 'postgresql',
      host => 'localhost',
      name => $database_name,
      user => $database_account,
      password => $database_password,
    },
  }

  Class['redmine'] <- Class['ruby']
  Class['redmine'] <- Package['postgresql-server-dev']
  Class['redmine'] <- Postgresql::Server::Database_grant[$database_account]
}
