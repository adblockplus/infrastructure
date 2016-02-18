# == Class: adblockplus
#
# The adblockplus class and the associated adblockplus:: namespace are
# used to integrate Puppet modules with each other, in order to assemble
# the setups used by the Adblock Plus project.
#
# === Parameters:
#
# [*authority*]
#   The authorative domain or zone associated with the current environment,
#   similar to the deprecated and soon to be removed $base::zone.
#
# [*users*]
#   A hash of adblockplus::user $name => $parameter items to set up in this
#   context, i.e. via Hiera.
#
# === Examples:
#
#   class {'adblockplus':
#     users => {
#       'pinocchio' => {
#         # see adblockplus::user
#       },
#     },
#   }
#
class adblockplus (
  $authority = hiera('adblockplus::authority', 'adblockplus.org'),
  $users = hiera_hash('adblockplus::users', {}),
) {

  # See https://issues.adblockplus.org/ticket/3574#comment:8
  class {'base':
    zone => $authority,
  }

  # Used as internal constant within adblockplus::* resources
  $directory = '/var/adblockplus'

  # A common location for directories specific to the adblockplus:: setups,
  # managed via Puppet, but accessible by all users with access to the system
  @file {$directory:
    ensure => 'directory',
    mode => 0755,
    owner => 'root',
  }

  # See modules/adblockplus/manifests/user.pp
  create_resources('adblockplus::user', $users)
}
