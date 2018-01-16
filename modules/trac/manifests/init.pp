class trac(
    $domain,
    $certificate,
    $private_key,
    $fcgi_config_dir = '/etc/nginx/trac.d',
    $is_default = false) inherits private::trac {

  package {['python-mysqldb','python-pip','subversion', 'tofrodos', 'graphviz']:
    ensure => present
  }

  include stdlib
  include nginx
  include spawn_fcgi

  file {$fcgi_config_dir:
    ensure => directory,
    owner => 'root',
    mode => '755',
    require => Package['nginx'],
  }

  nginx::hostconfig {$domain:
    content => "include $fcgi_config_dir/*;",
    is_default => $is_default,
    certificate => $certificate,
    private_key => $private_key,
    log => 'access_log_trac',
    require => File[$fcgi_config_dir],
  }

  user {'trac':
    ensure => present,
    comment => 'User of the trac installation',
    home => '/home/trac',
    managehome => true
  }

  class {'mysql::server':
    root_password => $database_root_password,
  }

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  }

  exec { 'install_trac':
    command => "pip install Trac==1.0.1",
    require => Package['python-pip'],
    unless => "python -c 'import trac,sys;sys.exit(0 if trac.__version__ == \"1.0.1\" else 1)'",
  }

  exec { 'install_BlackMagicTicketTweaks':
    command => "pip install svn+https://trac-hacks.org/svn/blackmagictickettweaksplugin/0.12/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import blackmagic'",
  }

  exec { 'install_SensitiveTickets':
    command => "pip install svn+https://trac-hacks.org/svn/sensitiveticketsplugin/0.11",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import sensitivetickets'",
  }

  exec { 'install_AccountManager':
    command => "pip install svn+https://trac-hacks.org/svn/accountmanagerplugin/tags/acct_mgr-0.4.4/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import acct_mgr'",
  }

  exec { 'install_TicketTemplate':
    command => "pip install svn+https://trac-hacks.org/svn/tractickettemplateplugin/0.11/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import tickettemplate'",
  }

  exec { 'install_AutocompleteUsers':
    command => "pip install svn+https://trac-hacks.org/svn/autocompleteusersplugin/trunk/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import autocompleteusers'",
  }

  exec { 'install_MasterTickets':
    command => "pip install svn+https://trac-hacks.org/svn/masterticketsplugin/trunk/",
    require => Package['subversion', 'python-pip', 'graphviz'],
    unless => "python -c 'import mastertickets'",
  }

  exec { 'install_NeverNotifyUpdater':
    command => "pip install svn+https://trac-hacks.org/svn/nevernotifyupdaterplugin/1.0/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import nevernotifyupdaterplugin'",
  }

  exec { 'install_ThemeEngine':
    command => "pip install TracThemeEngine",
    require => Package['python-pip'],
    unless => "python -c 'import themeengine'",
  }

  package { 'spambayes':
	ensure => "installed"
  }

  exec { 'install_TracSpamFilter':
    command => "pip install svn+https://svn.edgewall.org/repos/trac/plugins/1.0/spam-filter",
    require => Package[
	'spambayes',
	'python-pip'],
    unless => "python -c 'import tracspamfilter'",
  }

  exec { 'install_Tractags':
    command => "pip install svn+https://trac-hacks.org/svn/tagsplugin/tags/0.7/",
    require => Package['python-pip'],
    unless => "python -c 'import tractags'",
  }

  exec { 'install_PrivateTickets':
    command => "pip install svn+https://trac-hacks.org/svn/privateticketsplugin/tags/2.0.2/",
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import privatetickets'",
  }

  exec { 'install_TracXMLRPC':
    command => 'pip install svn+https://trac-hacks.org/svn/xmlrpcplugin/trunk/',
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import tracrpc'",
  }

  exec { 'install_TracHTTPAuth':
    command => 'pip install svn+https://trac-hacks.org/svn/httpauthplugin/trunk/',
    require => Package['subversion', 'python-pip'],
    unless => "python -c 'import httpauth'",
  }

  file { '/home/trac/trac.ini':
    ensure => present,
    source => 'puppet:///modules/trac/trac.ini',
    owner => 'trac',
    mode => '644',
  }

  file {'/home/trac/robots.txt':
    ensure => 'present',
    source => 'puppet:///modules/trac/robots.txt',
    owner => 'trac',
    mode => '644',
  }

  file {"trac_performance_fix_py":
    ensure => present,
    path => '/usr/local/lib/python2.7/dist-packages/trac_performance_fix.py',
    source => 'puppet:///modules/trac/trac_performance_fix.py',
    owner => 'root',
    mode => '644',
  }


  define instance (
      $config = 'trac/trac.ini.erb',
      $description = 'Issue Tracker',
      $location = '/',
      $logo = 'puppet:///modules/trac/logo.png',
      $database = 'trac',
      $permissions = 'puppet:///modules/trac/permissions.csv',
      $theme = 'puppet:///modules/trac/theme.css') {

    $database_password = $private::trac::database_password
    $environment = "environment-$name"
 
    mysql::db {$database:
      user => 'trac',
      password => $database_password,
      host => 'localhost',
      grant => ['all'],
      charset => 'utf8',
      collate => 'utf8_bin',
      require => Class['mysql::server'],
    }

    $location_base = regsubst($location, '/+$', '')

    file {"${trac::fcgi_config_dir}/${name}.conf":
      ensure => file,
      owner => 'root',
      mode => '644',
      content => template('trac/fcgi.conf.erb'),
      require => File[$trac::fcgi_config_dir],
      notify => Service['nginx'],
    }
  
    exec {"trac_env_${name}":
      command => shellquote(
        'trac-admin', "/home/trac/$environment", 'initenv', $description,
        "mysql://trac:${database_password}@localhost:3306/$database"),
      logoutput => true,
      path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      require => [
        Exec['install_trac'],
        Mysql_grant["trac@localhost/${database}.*"]],
      user => trac,
      unless => "test -d /home/trac/$environment",
    }

    file {"/home/trac/${environment}/conf/permissions.csv":
      ensure => present,
      owner => trac,
      source => $permissions,
      require => Exec["trac_env_$name"],
    }
  
    file {"/home/trac/$environment/conf/trac.ini":
      ensure => present,
      content => template($config),
      owner => trac,
      require => Exec["trac_env_$name"]
    }
  
    file {"/home/trac/$environment/htdocs/theme.css":
      ensure => present,
      source => $theme,
      owner => trac,
      require => Exec["trac_env_$name"],
    }
  
    exec {"update_env_$name":
      command => "trac-admin /home/trac/$environment upgrade",
      user => trac,
      path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      require => [
        File["/home/trac/$environment/conf/trac.ini"],
        Exec['install_SensitiveTickets'],
        Exec['install_BlackMagicTicketTweaks'],
        Exec['install_AccountManager'],
        Exec['install_AutocompleteUsers'],
        Exec['install_TicketTemplate'],
        Exec['install_NeverNotifyUpdater'],
        Exec['install_MasterTickets'],
        Exec['install_ThemeEngine'],
        Exec['install_Tractags'],
        Exec['install_TracSpamFilter'],
        Exec['install_PrivateTickets'],
        Exec['install_TracXMLRPC'],
        Exec['install_TracHTTPAuth']],
    }
  
    exec {"deploy_$name":
      command => "trac-admin /home/trac/$environment \
        deploy /home/trac/htdocs-$name \
        && fromdos /home/trac/htdocs-$name/cgi-bin/trac.fcgi \
        && chmod 755 /home/trac/htdocs-$name/cgi-bin/trac.fcgi",
      user => trac,
      path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      require => [
        Exec["update_env_$name"],
        Package["tofrodos"]],
    }
  
    file_line {"patch $name trac.fcgi":
      path => "/home/trac/htdocs-$name/cgi-bin/trac.fcgi",
      match => '^# Author.*$',
      line => "# Author\nimport trac_performance_fix",
      require => Exec["deploy_$name"],
    }

    file {"/home/trac/htdocs-$name/htdocs/common/logo.png":
      ensure => present,
      source => $logo,
      owner => trac,
      require => Exec["deploy_$name"],
    }

    spawn_fcgi::pool {"tracd_${name}":
      ensure => present,
      fcgi_app => "/home/trac/htdocs-$name/cgi-bin/trac.fcgi",
      socket => "/tmp/${name}-fastcgi.sock",
      mode => "0666",
      user => trac,
      children => 1,
      require => Exec["deploy_$name"],
    }

    logrotate::config {"trac_$name":
      content => template('trac/logrotate.erb'),
      ensure => 'present',
    }
  }

  # Daily restart required for log rotation of all instances at once
  cron {'restart-trac-daily':
    command => '/usr/sbin/service spawn-fcgi restart >/tmp/spawn-fcgi-restart.log',
    environment => hiera('cron::environment', []),
    hour => '1',
    minute => '0',
    user => 'root',
  }
}

