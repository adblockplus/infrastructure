# == Type: adblockplus::host::downloadserver
#
# Resource definitions for any host recognized, included automatically with type
# adblockplus::host if the current node's $::role is 'downloadserver'.
#
define adblockplus::host::downloadserver {

  # Unfortunately one cannot use a role here, as the resources on server16 are
  # not part of the configuration-management controlled services yet
  if $title == 'server16' {

    # https://issues.adblockplus.org/ticket/4663
    realize(Sshkey[$title])
  }
}
