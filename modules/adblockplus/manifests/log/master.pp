# == Class: adblockplus::log::master
#
# A server setup to collect and pre-process (i.e. anonymize and combine)
# log files using Logstash (https://logstash.net/) pipelines.
#
# === Parameters:
#
# [*uplinks*]
#   A hash of $name => $parameters resembling the servers registry within
#   file modules/private/hiera/hosts.yaml, which is used by default.
#
# === Examples:
#
#   class {'adblockplus::log::master':
#     uplinks => {
#       'filter1' => {
#         ip => '10.8.0.1',
#         ssh_public_key 'AAA...',
#       },
#     },
#   }
#
class adblockplus::log::master (
  $uplinks = hiera('adblockplus::log::master::uplinks', hiera('servers', {})),
) {

  include adblockplus::log
  realize(File[$adblockplus::log::directory])
  realize(User[$adblockplus::log::user])

  # Used as internal constants within adblockplus::log::* resources
  $data_directory = "$adblockplus::log::directory/data"
  $uplink_directory = "$adblockplus::log::directory/uplink"
  $import_script = '/usr/local/bin/adblockplus-log-import'

  # Mapping hiera values explicitly becomes obsolete with Puppet 3.x
  class {'logstash':
    contrib => hiera('logstash::contrib', false),
    ensure => hiera('logstash::ensure', 'running'),
    pipelines => hiera('logstash::pipelines', {}),
    version => hiera('logstash::version', '1.4'),
  }

  # Location for input sockets in Logstash pipeline configurations
  file {$uplink_directory:
    ensure => 'directory',
    group => $adblockplus::log::group,
    mode => 0750,
    owner => 'logstash',
    require => [
      File[$adblockplus::log::directory],
      Package['logstash'],
      User[$adblockplus::log::user],
    ],
  }

  # Default location for output files in Logstash pipeline configurations
  file {$data_directory:
    ensure => 'directory',
    before => Service['logstash'],
    group => 'logstash',
    mode => 0775,
    owner => 'root',
    require => [
      File[$adblockplus::log::directory],
      Package['logstash'],
    ],
  }

  # The Python script dispatching incoming logs
  file {$import_script:
    ensure => 'present',
    mode => 0755,
    require => User[$adblockplus::log::user],
    source => 'puppet:///modules/adblockplus/log/import.py',
  }

  # See modules/adblockplus/manifests/log/uplink.pp
  create_resources('adblockplus::log::uplink', $uplinks)
}
