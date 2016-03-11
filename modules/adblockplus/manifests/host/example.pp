# == Type: adblockplus::host::example
#
# An example on how to apply resource definitions that are specific to the
# current node's $::role, but need to recognize or correspond to a subset of
# all hosts within the same environment. One can introduce another manifest
# corresponding to the adblockplus::host::$::role pattern when integrating
# resources that are set up based on individual host information.
#
# This workaround is required due to the circumstance that module adblockplus
# must still remain Puppet 2.7 compatible, which does not feature sophisticated
# iteration over i.e. resource definitions or collectors, hence makes it very
# difficult to re-use information whilst maintaining clear abstraction.
#
# See type adblockplus::host for more information.
#
define adblockplus::host::example {

  # Puppetlab's stdlib allows for accessing host parameters
  $fqdn = getparam(Adblockplus::Host[$title], 'fqdn')

  # Examplary resource without side-effects
  notify {"$fqdn#example":
    message => "Place definitions requiring information about host $fqdn here",
  }
}
