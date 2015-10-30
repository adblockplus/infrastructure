# == Type: logstash::pipeline
#
# Manage Logstash (https://logstash.net/) pipeline configuration files.
#
# While one can directly provide the configuration $source or $content, one
# should note that a logstash::pipeline resource is actually the head of the
# logfile for concatenation (analogous to file_concat or module concat). Use
# logstash::fragment to assemble such a file from multiple resources.
#
# === Parameters:
#
# [*content*]
#   The configuration as-is, mutually exclusive with $source.
#
# [*ensure*]
#   Either 'present' or 'absent'.
#
# [*source*]
#   The configuration source location, mutually exclusive with $content.
#
# === Examples:
#
# Below please find a list of examples on how to use this type. Examples
# on how to configure a Logstash pipeline are provided by Elastic at
# https://www.elastic.co/guide/en/logstash/current/config-examples.html
#
#   # A pipeline setup using logstash::fragment
#   logstash::pipeline {'alpha':
#     ensure => 'present',
#   }
#
#   # A pipeline setup from a single template
#   logstash::pipeline {'beta':
#     content => template('custom/pipeline.erb'),
#   }
#
#   # An obsolete setup to be removed if present
#   logstash::pipeline {'gamma':
#     ensure => 'absent',
#   }
#
# For more information on how to use logstash::fragment with a pipeline
# like 'alpha' above please refer to the accompanying fragment.pp file.
#
define logstash::pipeline(
  $content = undef,
  $ensure = 'present',
  $source = undef,
) {

  $id = "logstash::pipeline#$title"
  $path = sprintf("/etc/logstash/conf.d/puppet-%s.conf", uriescape($title))

  if $ensure !~ /^(absent|purged)$/ {

    concat {$id:
      notify => Service['logstash'],
      path => $path,
      require => Package['logstash'],
    }

    concat::fragment {$id:
      content => $content,
      order => 0,
      source => $source,
      target => $id,
    }
  }
  elsif !defined(File[$path]) {

    file {$path:
      ensure => 'absent',
    }
  }
}
