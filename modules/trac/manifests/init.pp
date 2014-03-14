class trac(
    $domain,
    $is_default = false) inherits private::trac {
  package {['python-mysqldb','python-pip','subversion', 'tofrodos', 'graphviz']:
    ensure => present
  }

  include nginx, spawn-fcgi

  file {'/etc/nginx/adblockplus.org_sslcert.key':
    ensure => file,
    owner => root,
    mode => 0644,
    notify => Service['nginx'],
    before => Nginx::Hostconfig[$domain],
    require => Package['nginx'],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.key'
  }

  file {'/etc/nginx/adblockplus.org_sslcert.pem':
    ensure => file,
    owner => root,
    mode => 0400,
    notify => Service['nginx'],
    before => Nginx::Hostconfig[$domain],
    require => Package['nginx'],
    source => 'puppet:///modules/private/adblockplus.org_sslcert.pem'
  }

  nginx::hostconfig {$domain:
    content => template('trac/site.erb'),
    enabled => true
  }

  user {'trac':
    ensure => present,
    comment => 'User of the trac installation',
    home => '/home/trac',
    managehome => true
  }

  class {'mysql::server':
    root_password => $database_root_password
  }

  mysql::db {'trac':
    user => 'trac',
    password => $database_password,
    host => 'localhost',
    grant => ['all'],
    charset => 'utf8',
    collate => 'utf8_bin',
    require => Class['mysql::server']
  }

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  }

  exec { 'install_trac':
    command => "pip install Trac==1.0",
    require => Package['python-pip'],
    unless => "python -c 'import trac,sys;sys.exit(0 if trac.__version__ == \"1.0\" else 1)'",
  }

  exec { 'trac_env':
    command => "trac-admin /home/trac/environment initenv \"Adblock Plus issue tracker\" mysql://trac:${database_password}@localhost:3306/trac",
    require => [
      Exec['install_trac'],
      Mysql_grant['trac@localhost/trac.*']
    ],
    user => trac,
    unless => "test -d /home/trac/environment"
  }

  exec { 'install_BlackMagicTicketTweaks':
    command => "pip install svn+http://trac-hacks.org/svn/blackmagictickettweaksplugin/0.12/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import blackmagic'",
  }

  exec { 'install_SensitiveTickets':
    command => "pip install svn+http://trac-hacks.org/svn/sensitiveticketsplugin/trunk/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import sensitivetickets'",
  }

  exec { 'install_AccountManager':
    command => "pip install svn+http://trac-hacks.org/svn/accountmanagerplugin/tags/acct_mgr-0.4.3/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import acct_mgr'",
  }

  exec { 'install_TicketTemplate':
    command => "pip install svn+http://trac-hacks.org/svn/tractickettemplateplugin/0.11/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import tickettemplate'",
  }

  exec { 'install_AutocompleteUsers':
    command => "pip install svn+http://trac-hacks.org/svn/autocompleteusersplugin/trunk/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import autocompleteusers'",
  }

  exec { 'install_MasterTickets':
    command => "pip install svn+http://trac-hacks.org/svn/masterticketsplugin/trunk/",
    require => Package['subversion', 'python-pip', 'graphviz'],
    unless => "python -c 'import mastertickets'",
  }

  exec { 'install_NeverNotifyUpdater':
    command => "pip install svn+http://trac-hacks.org/svn/nevernotifyupdaterplugin/1.0/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import nevernotifyupdaterplugin'",
  }

  file {"/home/trac/environment/conf/trac.ini":
    ensure => present,
    content => template('trac/trac.ini.erb'),
    owner => trac,
    require => Exec['trac_env']
  }

  file {"/home/trac/htdocs/htdocs/common/adblockplus_logo.png":
    ensure => present,
    source => 'puppet:///modules/trac/adblockplus_logo.png',
    owner => trac,
    require => Exec['deploy']
  }

  exec {"update_env":
    command => "trac-admin /home/trac/environment upgrade",
    user => trac,
    require => [
      File['/home/trac/environment/conf/trac.ini'],
      Exec['install_SensitiveTickets'],
      Exec['install_BlackMagicTicketTweaks'],
      Exec['install_AccountManager'],
      Exec['install_AutocompleteUsers'],
      Exec['install_TicketTemplate'],
      Exec['install_NeverNotifyUpdater'],
      Exec['install_MasterTickets']]
  }

  exec {"deploy":
    command => "trac-admin /home/trac/environment deploy /home/trac/htdocs && fromdos /home/trac/htdocs/cgi-bin/trac.fcgi && chmod 755 /home/trac/htdocs/cgi-bin/trac.fcgi",
    user => trac,
    require => [
      Exec["update_env"],
      Package["tofrodos"]]
  }

  spawn-fcgi::pool {"tracd":
    ensure => present,
    fcgi_app => "/home/trac/htdocs/cgi-bin/trac.fcgi",
    socket => "/tmp/trac-fastcgi.sock",
    mode => "0666",
    user => trac,
    children => 1,
    require => Exec['deploy'],
  }

  file {"/home/trac/permissions.csv":
    ensure => present,
    owner => trac,
    source => 'puppet:///modules/trac/permissions.csv'
  }

}
