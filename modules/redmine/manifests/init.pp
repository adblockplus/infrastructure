# == Class: redmine
#
# A basic Redmine setup; in development / alpha state. Limitiations, for
# now, include:
#
# - Only a production environment is supported (RAILS_ENV)
# - Only the english default setup is ensured
# - A working Ruby environment (incl. e.g. bundler) is assumed
# - The chosen database is assumed to be setup with all dependencies
# - It is not yet implemented as a service, thus requires manual start
#
# === Parameters:
#
# [*database*]
#   The database configuration. This translates almost directly to the
#   production section in database.yml, except for 'name' (which aliases
#   the database: entry) and 'encoding' (which is always set to UTF-8).
#
# [*exec_path*]
#   The $PATH to use for any Exec resource. This translates directly into
#   the database.yml configuration, except for the 'name' (which aliases
#   the datatabase: key within the YAML file) and the 'encoding' (which is
#   always set to 'utf8').
#
# [*revision*]
#   The revision to use from the Redmine source repository.
#
# === Examples:
#
#   class {'redmine':
#     database => {
#       adapter => 'mysql2',
#       name => 'redmine',
#       host => 'localhost',
#       password => 'changeme',
#     },
#   }
#
class redmine(
  $database = {
    'adapter' => 'sqlite3',
    'name' => 'db/redmine.sqlite3',
  },
  $exec_path = '/usr/local/bin:/usr/bin:/bin',
  $revision = '3.0-stable',
) {

  $source = 'https://bitbucket.org/redmine/redmine-all'
  $directory = '/opt/redmine'

  Exec {
    logoutput => true,
    path => $exec_path,
  }

  Package {
    ensure => 'installed',
  }

  if !defined(Package['mercurial']) {
    package {'mercurial': }
  }

  if !defined(Package['imagemagick']) {
    package {'imagemagick': }
  }

  if !defined(Package['libmagickwand-dev']) {
    package {'libmagickwand-dev': }
  }

  if !defined(Package['pkg-config']) {
    package {'pkg-config': }
  }

  exec {'redmine-clone-source':
    command => shellquote('hg', 'clone', '--updaterev', $revision, $source, $directory),
    creates => $directory,
    require => Package['mercurial'],
  }

  exec {'redmine-gem-install-bundler':
    command => shellquote('gem', 'install', 'bundler'),
    unless => shellquote('ruby', '-e', 'require "bundler"'),
  }

  exec {'redmine-bundle-install':
    command => shellquote('bundle', 'install', '--without', 'development', 'test'),
    creates => "$directory/Gemfile.lock",
    cwd => $directory,
    notify => Exec['redmine-generate-secret-token'],
    require => [
      Package['imagemagick'],
      Package['libmagickwand-dev'],
      Package['pkg-config'],
      Exec['redmine-clone-source'],
      Exec['redmine-gem-install-bundler'],
    ],
  }

  file {'redmine-database-config':
    content => template('redmine/database.yml.erb'),
    ensure => 'present',
    path => "$directory/config/database.yml",
    require => Exec['redmine-clone-source'],
  }

  exec {'redmine-db-migrate':
    command => shellquote('bundle', 'exec', 'rake', 'db:migrate'),
    cwd => $directory,
    environment => 'RAILS_ENV=production',
    refreshonly => true,
    subscribe => File['redmine-database-config'],
  }

  exec {'redmine-generate-secret-token':
    command => shellquote('bundle', 'exec', 'rake', 'generate_secret_token'),
    cwd => $directory,
    environment => 'RAILS_ENV=production',
    refreshonly => true,
    require => Exec['redmine-db-migrate'],
    subscribe => Exec['redmine-bundle-install'],
  }

  exec {'redmine-load-default-data':
    command => shellquote('bundle', 'exec', 'rake', 'redmine:load_default_data'),
    cwd => $directory,
    environment => ['RAILS_ENV=production', 'REDMINE_LANG=en'],
    refreshonly => true,
    require => Exec['redmine-generate-secret-token'],
    subscribe => Exec['redmine-bundle-install'],
  }
}
