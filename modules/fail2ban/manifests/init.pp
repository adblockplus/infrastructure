# == Class: fail2ban
#
# Create and maintain fail2ban (http://www.fail2ban.org/) setups.
#
# == Parameters:
#
# [*jails*]
#   Provisions a jail.local adjacent to the default configuration.
#   By default entries will have the following parameters:
#     'enabled' => 'true',
#     'port' => 'all',
#     'maxretry' => 6,
#     'banaction' => 'iptables-allports',
#     'bantime' => 3600,
#
#   For the default banaction iptables-allports, the port parameter
#   is not used and only set here for documentation purposes. Note
#   that if 'banaction' is set to iptables-multiport, it requires that
#   the 'port' parameter contains one or more comma-separated ports or protocols.
#
# [*package*]
#   Overwrite the default package options, to fine-tune the target version (i.e.
#   ensure => 'latest') or remove fail2ban (ensure => 'absent' or 'purged')
#
# [*service*]
#   Overwrite the default service options.
#
# [*filters*]
#   Adds adittional filters to the filters.d folder.
#
# === Examples:
#
#  class {'fail2ban':
#    package => {ensure => 'present',},
#    service => {},
#    jails => {
#      'CVE-2013-0235' => {
#        'logpath' => '/var/log/nginx/access_log_hg',
#        'banaction' => 'iptables-multiport',
#        'port' => 'https, http',
#      }
#    },
#    filters => {
#      'CVE-2013-0235' => {
#        regexes => [
# 	   '^<HOST>.*\"WordPress\/.*',
# 	 ],
#      }
#    },
#  }
#
class fail2ban (
  $package = hiera('fail2ban::package', {}),
  $service = hiera('fail2ban::service', {}),
  $jails = hiera('fail2ban::jails', {}),
  $filters = hiera('fail2ban::filters', {}),
) {

  include stdlib

  $jail_default = {
    'enabled' => 'true',
    'port' => 'all',
    'maxretry' => 6,
    'banaction' => 'iptables-allports',
    'bantime' => 3600,
  }

  ensure_resource('package', $title, $package)

  $ensure = getparam(Package[$title], 'ensure') ? {
    /^(absent|purged)$/ => 'absent',
    default => 'present',
  }

  if ($ensure == 'present') {

    ensure_resource('service', $title, merge({
      hasrestart => true,
      hasstatus => true,
    }, $service))

    # See modules/fail2ban/manifests/filter.pp
    create_resources('fail2ban::filter', $filters)

    file {'/etc/fail2ban/jail.local':
      ensure => present,
      group => 'root',
      mode => '0644',
      owner => 'root',
      content => template("fail2ban/jail.erb"),
      notify => Service['fail2ban'],
      require => Package['fail2ban'],
    }

    Package[$title] -> File['/etc/fail2ban/jail.local']
    Service[$title] <~ Package[$title]
  }

}

