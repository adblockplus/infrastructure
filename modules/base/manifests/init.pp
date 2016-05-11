class base ($zone='adblockplus.org') {

  $servers = hiera('servers')
  create_resources(base::explicit_host_record, $servers)

  define explicit_host_record(
    $ip,
    $ssh_public_key = undef,
    $role           = undef,
    $dns            = undef,
    $groups         = undef,
  ) {

    $fqdn = $dns ? {
      undef => "$name.${base::zone}",
      default => $dns,
    }

    $ips = is_array($ip) ? {
      true => $ip,
      default => [$ip],
    }

    $public_key = $ssh_public_key ? {
      undef => undef,
      default => "ssh-rsa $ssh_public_key $fqdn",
    }

    adblockplus::host {$title:
      fqdn => $fqdn,
      groups => $groups,
      ips => $ips,
      name => $name,
      role => $role,
      public_key => $public_key,
    }
  }
}
