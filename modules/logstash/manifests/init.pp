# == Class: logstash
#
# Manage Logstash (https://logstash.net/) installations via APT.
#
# Please refer to the online documentation at Elastic for more information
# on the logstash software, it's usage and configuration options:
#
# https://www.elastic.co/guide/en/logstash/current/index.html
#
# === Parameters:
#
# [*contrib*]
#   Whether to realize Package['logstash-contrib'].
#
# [*ensure*]
#   Either 'present'/'stopped', 'running'/'started', or 'absent'/'purged'.
#   Note that Service['logstash'] is only realized implicitly when $ensure
#   is neither 'absent' nor 'purged'.
#
# [*pipelines*]
#   A hash to setup logstash::pipeline {$name: $parameter} resources.
#
# [*version*]
#   The https://packages.elasticsearch.org/logstash/%s/debian $version.
#
# === Examples:
#
#   class {'logstash':
#     contrib => true,
#     pipelines => {
#       'example' => {
#         # see type logstash::pipeline for a parameter reference
#       },
#     },
#   }
#
class logstash (
  $contrib = false,
  $ensure = 'running',
  $pipelines = {},
  $version = '1.4',
) {

  $ensure_file = $ensure ? {
    /^(absent|purged)$/ => 'absent',
    default => 'present',
  }

  apt::key {'logstash':
    ensure => $ensure_file,
    key => 'D88E42B4',
    key_content => template('logstash/elastic-logstash-gpg-key.erb'),
  }

  apt::source {'logstash':
    ensure => $ensure_file,
    include_src => false,
    location => "https://packages.elasticsearch.org/logstash/$version/debian",
    release => 'stable',
    require => Apt::Key['logstash'],
  }

  package {'logstash':
    ensure => $ensure ? {
      /^(absent|purged)$/ => $ensure,
      default => 'present',
    },
    require => Apt::Source['logstash'],
  }

  @package {'logstash-contrib':
    before => Service['logstash'],
    ensure => $ensure ? {
      /^(absent|purged)$/ => $ensure,
      default => 'present',
    },
    require => Package['logstash'],
  }

  @service {'logstash':
    enable => $ensure ? {
      /^(absent|purged)$/ => false,
      default => true,
    },
    ensure => $ensure ? {
      /^(running|started)$/ => 'running',
      default => 'stopped',
    },
    hasrestart => true,
    require => Package['logstash'],
  }

  file {'/usr/local/bin/logstash':
    ensure => $ensure_file,
    mode => 0755,
    source => 'puppet:///modules/logstash/logstash.sh',
    require => Package['logstash'],
  }

  if $contrib {
    realize(Package['logstash-contrib'])
  }

  if $ensure !~ /^(absent|purged)$/ {
    realize(Service['logstash'])
  }

  create_resources('logstash::pipeline', $pipelines)
}
