# == Class: adblockplus::web::mimeo
#
# Class adblockplus::web::mimeo registers the information received in a
# http/s petition with an specified format in an specific output.
#
# === Parameters:
#
# [*format*]
#   A string containing the desired format for logging.
#
#   '$remote_addr - - [$time_local] "$request" $status $bytes_sent "$http_referer"'
#
# [*port*]
#   An integer to setup the port where the script will be listening, defaults
#   to 8000.
#
# [*response*]
#   A string (like format parameter) representing the response sent to the
#   client.
#
# [*rotation*]
#   Overwrite the default log rotation configuration
#
class adblockplus::web::mimeo (
  $format = '',
  $port = 8000,
  $response = '',
  $rotation = {},
){
  include adblockplus

  ensure_packages(['python3'])

  realize(File['/var/adblockplus'])

  file {'/var/adblockplus/mimeo':
    ensure => 'directory',
    mode => '0755',
    owner => 'root',
    require => File['/var/adblockplus'],
  }

  file {'/usr/local/bin/mimeo.py':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode => 0755,
    source => 'puppet:///modules/adblockplus/mimeo.py',
    require => Package['python3'],
  }

  file {'/etc/systemd/system/mimeo.service':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode => 0644,
    content => template('adblockplus/mimeo.service.erb'),
    require => File['/usr/local/bin/mimeo.py'],
  }

  Exec{
    path => ['/usr/bin', '/bin'],
  }

  exec {'enable-service-mimeo':
    command => 'systemctl enable mimeo.service',
    user => 'root',
    unless => 'systemctl is-enabled mimeo.service',
    require => File['/etc/systemd/system/mimeo.service'],
  }

  service {'mimeo':
    ensure => 'running',
    hasrestart => false,
    provider => 'systemd',
    require => Exec['enable-service-mimeo'],
    subscribe => File['/usr/local/bin/mimeo.py'],
  }

  exec {'reload-mimeo-daemon':
    notify => Service['mimeo'],
    command => 'systemctl daemon-reload',
    subscribe => File['/etc/systemd/system/mimeo.service'],
    refreshonly => true,
  }

  # https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-source
  $default_content = $rotation['source'] ? {
    undef => join([
      '/var/adblockplus/mimeo/data {',
      '  daily',
      '  rotate 30',
      '  compress',
      '  missingok',
      '  nodateext',
      '  postrotate',
      '    service mimeo restart',
      '  endscript',
      '}',
    ], "\n"),
    default => undef,
  }

  ensure_resource('logrotate::config', 'mimeo_data', merge({
    content => $default_content,
    ensure => 'present',
  }, $rotation))
}

