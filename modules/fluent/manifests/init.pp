# == Class: fluent
#
# Create and maintain Fluentd (https://www.fluentd.org/) setups.
#
# == Parameters:
#
# [*config*]
#   Overwrite the default concat/file options for the Fluentd agent config.
#
# [*key*]
#   Overwrite the default apt::key used (given Class['apt'] is defined).
#
# [*package*]
#   Overwrite the default package options, to fine-tune the target version (i.e.
#   ensure => 'latest') or remove Fluentd (ensure => 'absent' or 'purged')
#
# [*service*]
#   Overwrite the default service options.
#
# [*source*]
#   Overwrite the default apt::source used (given Class['apt'] is defined).
#
# [*user*]
#   Overwrite the default user options, i.e. to provide a $HOME directory.
#
# === Examples:
#
#   class {'fluent':
#     package => {
#       ensure => 'latest',
#     },
#     user => {
#       managehome => true,
#       shell => '/bin/sh',
#     },
#   }
#
#   class {'fluent':
#     package => {
#       ensure => 'absent',
#     },
#   }
#
class fluent (
  $config = {
    content => template('fluent/td-agent.conf.erb'),
  },
  $key = {
    key => 'A12E206F',
    key_content => template("fluent/td-gpg-key.erb"),
  },
  $package = {},
  $service = {},
  $source = {
    location => sprintf(
      'https://packages.treasuredata.com/2/%s/%s',
      downcase($lsbdistid), downcase($lsbdistcodename)
    ),
    release => downcase($lsbdistcodename),
    repos => 'contrib',
  },
  $user = {},
) {

  include stdlib

  ensure_resource('package', $title, merge({
    name => 'td-agent',
  }, $package))

  # Used as default $ensure parameter for most resources below
  $ensure = getparam(Package[$title], 'ensure') ? {
    /^(absent|purged|held)$/ => 'absent',
    default => 'present',
  }

  ensure_resource('file', $title, merge({
    ensure => $ensure,
    group => 'root',
    mode => '0644',
    owner => 'root',
    path => '/etc/td-agent/td-agent.conf',
  }, $config))

  ensure_resource('user', $title, merge({
    ensure => $ensure,
    name => 'td-agent',
    gid => 'td-agent',
    home => '/home/td-agent',
    shell => '/bin/false',
  }, $user))

  Package[$title] -> File[$title]
  Package[$title] -> User[$title]

  # Used as internal shortcuts within fluent::* resource definitions
  $directory = regsubst(getparam(File[$title], 'path'), '/[^/]+$', '')
  $group = getparam(User[$title], 'gid')

  # Service resources don't properly support the concept of absence
  if ($ensure == 'present') or ($service['ensure'] != undef) {

    ensure_resource('service', $title, merge({
      name => 'td-agent',
    }, $service))

    Service[$title] <~ File[$title]
    Service[$title] <~ Package[$title]
    Service[$title] <~ User[$title]
  }

  # Base directories for fluent::config and fluent::plugin resources
  file {[
    "$directory/config.d",
    "$directory/plugin",
  ]:
    before => File[$title],
    ensure => getparam(File[$title], 'ensure') ? {
      /^(present|link)$/ => 'directory',
      default => 'absent',
    },
    group => getparam(File[$title], 'group'),
    mode => 0755,
    owner => getparam(File[$title], 'owner'),
    require => Package[$title],
  }

  # The only package provider recognized implicitly
  if getparam(Package[$title], 'provider') == 'apt' {

    ensure_resource('apt::key', $title, merge({
      ensure => $ensure,
      name => 'treasure-data',
    }, $key))

    ensure_resource('apt::source', $title, merge({
      ensure => $ensure,
      include_src => false,
      name => 'treasure-data',
    }, $source))

    Apt::Source[$title] <- Apt::Key[$title]
    Apt::Source[$title] -> Package[$title]
  }
}
