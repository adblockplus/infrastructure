# == Type: adblockplus::host::monitoringserver
#
# Nagios definitions for any host recognized, included automatically with type
# adblockplus::host if the current node's $::role is 'monitoringserver'.
#
define adblockplus::host::monitoringserver {

  $ensure = getparam(Adblockplus::Host[$title], 'ensure')
  $fqdn = getparam(Adblockplus::Host[$title], 'fqdn')
  $groups = getparam(Adblockplus::Host[$title], 'groups')

  nagios_host {$fqdn:
    ensure => $ensure,
    hostgroups => $groups,
    use => 'generic-host',
  }
}
