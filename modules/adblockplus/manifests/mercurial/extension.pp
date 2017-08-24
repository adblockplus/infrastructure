# == Type: adblockplus::mercurial::extension
#
# Setup rotation for a particular log file.
#
# === Parameters:
#
# [*config*]
#   Overwrite the default hgrc.d/$name file for Mercurial extensions.
#
# [*package*]
#   Overwrite the default package/extension options.
#
# === Examples:
#
#   adblockplus::mercurial::extension {'example':
#     name => 'pager',
#     config => {
#       content => join([
#         '[extensions]',
#         'pager = ',
#         '[pager]',
#         'pager = LESS=FSRX less',
#       ], "\n"),
#     }
#   }
#
#   adblockplus::mercurial::extension {'hggit':
#     package => {
#       'ensure' => 'latest',
#       'name' => 'hg-git',
#       'provider' => 'pip',
#       'install_options' => ['https://pypi.python.org/pypi/hg-git'],
#     },
#   }
#
#   adblockplus::mercurial::extension {'hgext.git':
#     package => {
#       'ensure' => 'absent',
#       'name' => 'mercurial-git',
#     },
#   }
#
define adblockplus::mercurial::extension (
  $config = {},
  $package = undef,
) {

  include adblockplus::mercurial
  include stdlib

  # https://docs.puppet.com/puppet/latest/lang_conditional.html#selectors
  # https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-content
  # https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-source
  $default_content = $config['source'] ? {
    undef => template('adblockplus/mercurial/hgext.erb'),
    default => undef,
  }

  # https://forge.puppet.com/puppetlabs/stdlib#ensure_resource
  # https://forge.puppet.com/puppetlabs/stdlib#merge
  ensure_resource('file', "$name.rc", merge({
    content => $default_content,
    ensure => ensure_file_state($adblockplus::mercurial::ensure),
    path => "/etc/mercurial/hgrc.d/$name.rc",
  }, $config))

  # https://docs.puppet.com/puppet/latest/lang_relationships.html
  File["$name.rc"] <- Package['mercurial']

  # https://docs.puppet.com/puppet/latest/function.html#defined
  if defined('$package') {

    ensure_resource('package', $name, merge({
      ensure => $adblockplus::mercurial::ensure,
      require => Package['python-dev'],
    }, $package))

    Package[$name] <- Package['mercurial']
  }
}
