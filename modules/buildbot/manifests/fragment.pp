# == Type: buildbot::fragment
#
# Manage Buildbot (https://buildbot.net/) master configuration fragments.
#
# === Parameters:
#
# [*authority*]
#   The master instance to append the configuration fragment to.
#
# [*content*]
#   The configuration fragment's content. Mutually exclusive with $source.
#
# [*order*]
#   An indicator for concat::fragment ordering.
#
# [*source*]
#   The configuration fragment's content. Defaults to $title. Mutually
#   exclusive with $content.
#
# === Examples:
#
#   buildbot::fragment {
#     authority => Buildbot::Master['example'],
#     content => "# additional python code for master.cfg",
#   }
#
define buildbot::fragment(
  $authority,
  $content = '',
  $order = 50,
  $source = '',
) {

  $master = getparam($authority, 'title')
  $basedir = getparam($authority, 'basedir')
  $config = "$basedir/master.cfg"

  realize(Concat[$config])
  realize(Concat::Fragment[$config])

  concat::fragment {"buildbot::fragment#$title":
    content => $content,
    order => $order,
    source => "$content$source" ? {
      '' => $title,
      default => $source,
    },
    target => $config,
  }
}
