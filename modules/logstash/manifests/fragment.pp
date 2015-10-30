# == Type: logstash::fragment
#
# Manage Logstash (https://logstash.net/) configuration file fragments.
#
# === Parameters:
#
# [*content*]
#   The configuration as-is, mutually exclusive with $source.
#
# [*ensure*]
#   Either 'present' or 'absent'.
#
# [*order*]
#   Any index for lexical odering of fragments within the generated file.
#
# [*source*]
#   The configuration source location, mutually exclusive with $content.
#
# [*target*]
#   The name or resource of the target pipeline configuration.
#
# === Examples:
#
#   logstash::fragment {'input':
#     content => template('custom/pipeline-inputs.erb'),
#     order => 20,
#     target => Logstash::Pipeline['custom'],
#   }
#
#   logstash::fragment {'filter':
#     content => template('custom/pipeline-filters.erb'),
#     order => 40,
#     target => Logstash::Pipeline['custom'],
#   }
#
#   logstash::fragment {'output':
#     content => template('custom/pipeline-outputs.erb'),
#     order => 60,
#     target => Logstash::Pipeline['custom'],
#   }
#
define logstash::fragment(
  $content = undef,
  $ensure = 'present',
  $order = 10,
  $source = undef,
  $target = 'default',
) {

  if is_string($target) {
    $pipeline = Logstash::Pipeline[$target]
  }
  else {
    $pipeline = $target
  }

  $pipeline_title = getparam($pipeline, 'title')
  $pipeline_id = "logstash::pipeline#$pipeline_title"

  concat::fragment {"logstash::fragment#$title":
    content => $content,
    ensure => $ensure,
    order => $order,
    source => $source,
    target => $pipeline_id,
  }
}
