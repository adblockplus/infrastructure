# == Type: adblockplus::log::uplink
#
# Used internally by class adblockplus::log::master to establish an SSH
# uplink for each known server, both identifying and authenticating the
# client by examining its $ip addresses and $ssh_public_key, i.e.:
#
#   # write into master:/var/adblockplus/log/uplink/$HOSTNAME/$@
#   client# ssh -i /etc/ssh/ssh_host_rsa_key log@master $@ < log.1.gz
#
# Note the uplink itself being just an SSH layer for upstream I/O, meant
# to become integrated as a client's post rotation command or similar.
#
# === Parameters:
#
# Identical to base::explicit_host_records.
#
# === Examples:
#
#   adblockplus::log::uplink {'example':
#     ip => ['10.8.0.1'],
#     ssh_authorized_key => 'AAA...',
#   }
#
define adblockplus::log::uplink (
  $ip,
  $ssh_public_key = undef,
  $role = undef,
  $dns = undef,
  $groups = undef,
) {

  include adblockplus::log::master

  $import_command = shellquote([
    $adblockplus::log::master::import_script,
    '--source', $dns ? {undef => $name, default => $dns},
    '--target', $adblockplus::log::master::uplink_directory,
  ])

  $source_address_pattern = is_array($ip) ? {
    true => join($ip, ','),
    default => $ip,
  }

  ssh_authorized_key {"adblockplus::log::uplink#$name":
    ensure => $ssh_public_key ? {
      undef => 'absent',
      default => 'present',
    },
    key => $ssh_public_key,
    name => $name,
    options => [
      "command=\"$import_command -- \$SSH_ORIGINAL_COMMAND\"",
      "from=\"$source_address_pattern\"",
      'no-agent-forwarding',
      'no-port-forwarding',
      'no-pty',
      'no-X11-forwarding',
    ],
    require => File[$adblockplus::log::master::uplink_directory],
    type => 'ssh-rsa',
    user => $adblockplus::log::user,
  }
}
