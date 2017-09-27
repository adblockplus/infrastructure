# http://hub.eyeo.com/issues/3913
define adblockplus::sudoers (
  $config,
) {

  # modules/adblockplus/manifests/sudo.pp
  include adblockplus::sudo

  # https://forge.puppet.com/puppetlabs/stdlib#ensure_resource
  # https://forge.puppet.com/puppetlabs/stdlib#merge
  # modules/adblockplus/lib/puppet/parser/functions/ensure_file_state.rb
  ensure_resource('file', "adblockplus::sudoers#$name", merge({
    ensure => ensure_file_state(Package['sudo']),
    group => 'root',
    mode => '0440',
    owner => 'root',
    path => "/etc/sudoers.d/$name",
  }, $config))
}
