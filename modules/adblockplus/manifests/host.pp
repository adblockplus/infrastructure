# == Type: adblockplus::host
#
# Manage host information for any node within the Adblock Plus infrastructure.
#
# === Parameters:
#
# [*ensure*]
#   Whether to ensure any host-related resources being 'present' or 'absent'.
#   Note that implicit realization of embedded resources only takes place if
#   $ensure is 'absent'.
#
# [*fqdn*]
#   The fully qualified domain name associated with the host. See the examples
#   section below on how this piece of information is supposed to be re-used.
#
# [*groups*]
#   A list of logical groups the host is associated with, i.e. for direct or
#   indirect translation into nagios_hostgroup names or similar. This parameter
#   is considered meta-information and not processed by type adblockplus::host.
#
# [*ips*]
#   A list of one or more IPv4 and IPv6 addresses associated with the host,
#   the first one of which is considered the primary IP address, and each of
#   which is included as $alias in the (virtual) Sshkey[$title] resource.
#
# [*public_key*]
#   The host's public (SSH) key, i.e "ssh-rsa AA.... host1.example.com", for
#   use with the (virual) Sshkey[$title] resource. Note that this implies the
#   default public key of the host being used, namely the first one offered
#   during the SSL handshake.
#
# [*role*]
#   The name of the host's primary role, if any. This parameter is considered
#   meta-information and not processed by type adblockplus::host.
#
# === Examples:
#
#   # Hosts being 'present' do not imply realization of embedded resources
#   adblockplus::host {'node1':
#     ensure => 'present',
#     ips => ['10.8.0.1'],
#   }
#
#   # Explicit realization of /etc/hosts and /etc/ssh/ssh_known_hosts records
#   realize(Host['node1'])
#   realize(Sshkey['node1'])
#
#   # Global realization, i.e. when creating a node all others can access
#   realize(Host<|tag == 'adblockplus::host'|>)
#   realize(Sshkey<|tag == 'adblockplus::host'|>)
#
#   # Addressing (meta-) parameters for re-using their values
#   $fqdn = getparam(Adblockplus::Host['node1'], 'fqdn')
#   $primary_ip = getparam(Host['node1'], 'ip')
#   $key_type = getparam(Sshkey['node1'], 'type')
#
#   # Resources associated with 'absent' hosts are always realized
#   adblockplus::host {'node0':
#     ensure => 'absent',
#   }
#
define adblockplus::host (
  $ensure = 'present',
  $fqdn = "$name.$adblockplus::authority",
  $groups = [],
  $ips = [],
  $public_key = undef,
  $role = undef,
) {

  include adblockplus
  include stdlib

  case $public_key {

    undef: {
      $sshkey_ensure = 'absent'
      $sshkey_key = undef
      $sshkey_type = undef
    }

    default: {
      $sshkey_ensure = $ensure
      $sshkey = split($public_key, '\s+')
      $sshkey_type = $sshkey[0]
      $sshkey_key = $sshkey[1]
    }
  }

  @host {$title:
    ensure => $ensure,
    ip => pick($ips[0], '0.0.0.0'),
    name => $fqdn,
    tag => ['adblockplus::host'],
  }

  @sshkey {$title:
    ensure => $sshkey_ensure,
    host_aliases => $ips,
    key => $sshkey_key,
    name => $fqdn,
    require => File['/etc/ssh/ssh_known_hosts'],
    tag => ['adblockplus::host'],
    type => $sshkey_type,
  }

  if $ensure == 'absent' {
    realize(Host[$title])
    realize(Sshkey[$title])
  }

  if $::role != undef and manifest_exists("adblockplus::host::$::role") {
    ensure_resource("adblockplus::host::$::role", $title, {name => $name})
  }
}
