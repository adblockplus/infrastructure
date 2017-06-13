# == Class: adblockplus::legacy
#
# A container for migrating obsolete global resources, included with the
# adblockplus class. See http://hub.eyeo.com/issues/1541 for more information.
#
class adblockplus::legacy {

  # Formerly included with class statsclient
  user {'stats':
    ensure => 'absent',
  }

  # User resources cannot remove the associated $HOME directory
  file {'/home/stats':
    ensure => 'absent',
    force => true,
    recurse => true,
  }
}
