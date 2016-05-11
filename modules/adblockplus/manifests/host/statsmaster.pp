# == Type: adblockplus::host::statsmaster
#
# Nagios definitions for any host recognized, included automatically with type
# adblockplus::host if the current node's $::role is 'statsmaster'.
#
define adblockplus::host::statsmaster {

  realize(Host[$title])
  realize(Sshkey[$title])
}
