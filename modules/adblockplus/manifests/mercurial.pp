# == Class: adblockplus::mercurial
#
# Manage Mercurial (https://www.mercurial-scm.org/) resources.
#
# === Parameters:
#
# [*config*]
#   Overwrite the default hgrc file options for the Mercurial config.
#
# [*package*]
#   Overwrite the default package options.
#
# === Examples:
#
#   class {'adblockplus::mercurial':
#     package => {
#       ensure => 'latest',
#     },
#   }
#
class adblockplus::mercurial (
  $config = {},
  $package = {},
) {

  # https://forge.puppet.com/puppetlabs/stdlib
  include stdlib

  # https://forge.puppet.com/puppetlabs/stdlib#ensure_resource
  ensure_resource('package', 'mercurial', $package)

  # https://forge.puppet.com/puppetlabs/stdlib#getparam
  $package_ensure = getparam(Package['mercurial'], 'ensure')

  # https://docs.puppet.com/puppet/latest/lang_conditional.html#selectors
  $ensure = $package_ensure ? {
    /^(absent|latest|present|purged|true)$/ => $package_ensure,
    default => 'present',
  }

  # https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-content
  # https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-source
  $default_content = $config['source'] ? {
    undef => template('adblockplus/mercurial/hgrc.erb'),
    default => undef,
  }

  # https://forge.puppet.com/puppetlabs/stdlib#merge
  ensure_resource('file', 'hgrc', merge({
    ensure => ensure_file_state(Package['mercurial']),
    group => 'root',
    mode => '0644',
    owner => 'root',
    path => '/etc/mercurial/hgrc',
    content => $default_content,
  }, $config))

  # https://docs.puppet.com/puppet/latest/lang_relationships.html
  Package['mercurial'] -> File['hgrc']

  # https://docs.puppet.com/puppet/latest/function.html#createresources
  $extensions = hiera_hash('adblockplus::mercurial::extensions', {})
  create_resources('adblockplus::mercurial::extension', $extensions)
}
