# == Class: hgweb
#
# A hgweb server setup.
#
# === Parameters:
#
# [*domain*]
#   The auhority part of the URL the instance is associated with.
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
# [*hgaccess*]
#   A prototype directory source for the hgaccess repository.
#
# === Examples:
#
#   class {'hgweb':
#     domain => 'localhost',
#   }
#
class hgweb(
  $domain,
  $is_default = false,
  $certificate = hiera('hgweb::certificate', 'undef'),
  $private_key = hiera('hgweb::private_key', 'undef'),
  $hgaccess = 'puppet:///modules/hgweb/hgaccess',
) {

  include ssh, nginx

  $required_packages = ['mercurial-common', 'python-flup', 'spawn-fcgi']
  ensure_packages($required_packages)

  class {'sitescripts':
    sitescriptsini_content => template('hgweb/sitescripts.ini.erb'),
  }

  user {'hg':
    comment => 'hgweb',
    groups => ['www-data'],
    home => '/home/hg',
    managehome => true,
    shell => '/bin/bash',
  }

  file {'/home/hg/.ssh':
    ensure => 'directory',
    group => 'hg',
    mode => 0750,
    owner => 'hg',
    require => User['hg'],
  }

  file {'/home/hg/web':
    ensure => 'directory',
    group => 'hg',
    mode => 0755,
    owner => 'hg',
    require => User['hg'],
  }

  file {'/home/hg/web/hgaccess':
    ensure => 'directory',
    group => 'hg',
    mode => 0644,
    owner => 'hg',
    recurse => true,
    replace => false,
    require => File['/home/hg/web'],
    source => $hgaccess,
  }

  file {'/home/hg/web/hgaccess/.hg/hgrc':
    content => template('hgweb/hgrc.erb'),
    group => 'hg',
    mode => 0644,
    owner => 'hg',
    require => [
      Class['sitescripts'],
      Exec['hgaccess_init'],
    ],
  }

  exec {'hgaccess_init':
    command => 'hg init .',
    creates => '/home/hg/web/hgaccess/.hg',
    cwd => '/home/hg/web/hgaccess',
    logoutput => true,
    path => '/usr/local/bin:/usr/bin:/bin',
    require => File['/home/hg/web/hgaccess'],
    user => 'hg',
  }

  exec {'hgaccess_commit':
    command => 'hg add . && hg commit -u Puppet -m "Initial commit"',
    creates => '/home/hg/.ssh/authorized_keys',
    cwd => '/home/hg/web/hgaccess',
    environment => ['PYTHONPATH=/opt/sitescripts'],
    logoutput => true,
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File['/home/hg/web/hgaccess/.hg/hgrc'],
      File['/home/hg/.ssh'],
    ],
    user => 'hg',
  }

  concat::fragment {'sshd_user_hg':
    content => 'Match User hg
      AllowTcpForwarding no
      X11Forwarding no
      AllowAgentForwarding no
      GatewayPorts no
      ForceCommand cd ~/web && PYTHONPATH=/opt/sitescripts hg-ssh $HGREPOS
    ',
    order => '99',
    target => 'sshd_config',
  }

  file {'/etc/hgweb.ini':
    mode => 644,
    require => Package[$required_packages],
    source => 'puppet:///modules/hgweb/hgweb.ini',
  }

  file {'/opt/hgweb.fcgi':
    mode => 755,
    require => File['/etc/hgweb.ini'],
    source => 'puppet:///modules/hgweb/hgweb.fcgi',
  }

  file {'/etc/init.d/hgweb':
    mode => 755,
    require => File['/opt/hgweb.fcgi'],
    source => 'puppet:///modules/hgweb/hgweb.sh',
  }

  file {'/home/hg/web/robots.txt':
    group => 'hg',
    mode => 0644,
    owner => 'hg',
    require => File['/home/hg/web'],
    source => 'puppet:///modules/hgweb/robots.txt',
  }

  service {'hgweb':
    enable => true,
    ensure => 'running',
    hasrestart => true,
    hasstatus => false,
    pattern => 'hgweb.fcgi',
    require => File['/etc/init.d/hgweb'],
    subscribe => File['/etc/hgweb.ini'],
  }

  nginx::hostconfig {$domain:
    certificate => $certificate ? {
      'undef' => undef,
      default => $certificate,
    },
    source => 'puppet:///modules/hgweb/nginx.conf',
    is_default => $is_default,
    log => 'access_log_hg',
    private_key => $private_key ? {
      'undef' => undef,
      default => $private_key,
    },
  }
}
