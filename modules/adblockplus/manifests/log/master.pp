# == Class: adblockplus::log::master
#
# A server setup to collect and pre-process (i.e. anonymize and combine)
# log files using Logstash (https://logstash.net/) pipelines.
#
class adblockplus::log::master {

  include adblockplus
  realize(File[$adblockplus::directory])

  # Mapping hiera values explicitly becomes obsolete with Puppet 3.x
  class {'logstash':
    contrib => hiera('logstash::contrib', false),
    ensure => hiera('logstash::ensure', 'running'),
    pipelines => hiera('logstash::pipelines', {}),
    version => hiera('logstash::version', '1.4'),
  }

  # Default location for output files in Logstash pipeline configurations
  file {"$adblockplus::directory/log":
    before => Service['logstash'],
    group => 'logstash',
    mode => 0775,
    require => [
      File[$adblockplus::directory],
      Package['logstash'],
    ],
  }
}
