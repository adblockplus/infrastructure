# == Type: nodejs::package
#
# Manage nodejs packages.
#
# === Parameters:
#
# [*ensure*]
#  Translated directly into the state of installed/uninstalled
#  package.
#
# [*options*]
#  A list of zero or more options to install the package.
#
define nodejs::package (
  $ensure = 'present',
) {

  $check_command = [
    "npm", "list",
    "--global",
    "--parseable",
    $name,
  ]

  if ensure_state($ensure) {
    $command = [
      "npm",
      "install", "--global",
      $title,
    ]

    $unless = shellquote($check_command)
    $onlyif = undef
  }
  else {
    $command = [
      "npm",
      "uninstall", "--global",
      $title,
    ]

    $unless = undef
    $onlyif = shellquote($check_command)
  }

  exec {"nodejs_package_$title":
    path => ["/usr/bin", "/bin"],
    command => shellquote($command),
    require => Package['nodejs'],
    onlyif => $onlyif,
    unless => $unless,
  }
}

