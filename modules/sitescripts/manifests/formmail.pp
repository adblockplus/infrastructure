# == Class: sitescripts::formmail
#
# Manage formmail templates resources.
#
# === Parameters:
#
# [*directory*]
#   Custom parameter for formmail templates' directory.
#
# [*ensure*]
#   General target policy for Puppet resources, supported values include
#   "present", "latest", "absent" and "purged"
#
class sitescripts::formmail(
  $directory = {},
  $ensure = 'present',
) {

  include sitescripts
  include stdlib
  include spawn_fcgi

  ensure_resource('file', $title, merge({
    'ensure' => ensure_directory_state($ensure),
    'path' => "${::sitescripts::directory_path}/formmail",
  }, $directory))

  $directory_path = getparam(File[$title], 'path')
  $templates_raw = hiera_hash('sitescripts::formmail::templates', {})

  $templates = parsejson(inline_template('<%= require "json";
    @templates_raw.map do |key, value|
      value["path"] ||= "#{@directory_path}/#{key}"
      ["#{@title}##{key}", value]
    end.to_h.to_json
  %>'))

  create_resources('file', $templates, {
    ensure => ensure_file_state($ensure),
    tag => 'formmail_template',
    notify => Service['spawn-fcgi'],
  })

  File[$title] -> File<|tag == 'formmail_template' |>
  File[$title] <- File[$::sitescripts::title]
}
