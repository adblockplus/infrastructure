# == Type: adblockplus::host::statsmaster
#
# Nagios definitions for any host recognized, included automatically with type
# adblockplus::host if the current node's $::role is 'statsmaster'.
#
define adblockplus::host::statsmaster {

  $ensure = getparam(Adblockplus::Host[$title], 'ensure')
  $role = getparam(Adblockplus::Host[$title], 'role')

  realize(Host[$title])
  realize(Sshkey[$title])

  if $ensure == 'present' {

    include sitescripts
    $fqdn = getparam(Adblockplus::Host[$title], 'fqdn')

    # https://issues.adblockplus.org/ticket/3638#comment:17
    if $role == 'filterserver' {

      sitescripts::configfragment {"mirror#$title":
        content => join([
          "# Filter mirror $fqdn",
          "mirror_$name=subscription ssh://stats@$fqdn/access_log_easylist_downloads.1.gz",
          "mirror_n_$name=notification ssh://stats@$fqdn/access_log_notification.1.gz",
          ""
        ], "\n"),
      }
    }

    # https://issues.adblockplus.org/ticket/4728
    if $role == 'downloadserver' {

      sitescripts::configfragment {"mirror#$title":
        content => join([
          "# Download mirror $fqdn",
          "mirror_$name=download ssh://stats@$fqdn/access_log_downloads.1.gz",
          ""
        ], "\n"),
      }
    }
    elsif $role == 'updateserver' {

      sitescripts::configfragment {"mirror#$title":
        content => join([
          "# Update mirror $fqdn",
          "mirror_$name=update ssh://stats@$fqdn/access_log_update.1.gz",
          ""
        ], "\n"),
      }
    }
  }
}
