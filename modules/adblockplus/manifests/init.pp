# == Class: adblockplus
#
# The adblockplus class and the associated adblockplus:: namespace are
# used to integrate Puppet modules with each other, in order to assemble
# the setups used by the Adblock Plus project.
#
class adblockplus {

  # Used as internal constant within adblockplus::* resources
  $directory = '/var/adblockplus'

  # A common location for directories specific to the adblockplus:: setups,
  # managed via Puppet, but accessible by all users with access to the system
  @file {$directory:
    ensure => 'directory',
    mode => 0755,
    owner => 'root',
  }
}
