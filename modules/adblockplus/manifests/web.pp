# == Class: adblockplus::web
#
# Default root namespace for integrating custom web resources.
#
# See http://hub.eyeo.com/issues/1980.
#
# === Parameters:
#
# [*directory*]
#   Custom parameters for the /var/www directory.
#
# [*ensure*]
#   General resource policy, i.e. "present" or "absent".
#
class adblockplus::web (
  $directory = {},
  $ensure = 'present',
) {

  ensure_resource('file', '/var/www', merge({
    'mode' => '0755',
  }, $directory, {
    'ensure' => ensure_directory_state(pick($directory['ensure'], $ensure)),
    'path' => '/var/www',
  }))
}
