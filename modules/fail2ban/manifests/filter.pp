# == Type: fail2ban::filter
#
# Manage filter information and files for any custom filter.
#
# == Parameters:
#
# [*regexes*]
#   Array of strings containing the regular expressions applied to
#   the filter.
#
# [*ensure*]
#   Translates directly into the state of the file resource.
#
# === Examples:
#
#   fail2ban::filter {'CVE-2013-0235':
#     regexes => [
#       '^<HOST>.*\"WordPress\/.*',
#	'^.*\"WordPress\/.*<HOST>.*',
#     ],
#     'ensure' => 'present',
#   }
#
define fail2ban::filter (
  $regexes = [],
  $ensure = 'present',
) {

  include fail2ban
  include stdlib

  if (size($regexes) == 0) and ($ensure == 'present') {
    fail("An array of one or more regular expressions is needed.")
  }

  # The $name parameter is used to compose the file name.
  file {"/etc/fail2ban/filter.d/$name.conf":
    ensure => $ensure,
    content => template("fail2ban/filter.erb"),
    group => 'root',
    mode => '0644',
    owner => 'root',
    require => Package['fail2ban'],
    notify => Service['fail2ban'],
  }
}

