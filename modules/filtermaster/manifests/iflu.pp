# == Class: filtermaster::iflu
#
#  This class manages the asociated resources for the incremental filter
#  lists updates (aka iflu)
#
# === Parameters:
#
# [*ensure*]
#   General resource policy, i.e. "present" or "absent".
#
# [*filterlists*]
#   A hash of filtermaster::iflu::filterlist items to set up in this
#   context, via Hiera, exclusively.
#
class filtermaster::iflu (
  $ensure = 'present',
  $filterlists = {},
) {

  # python-abp contains a script called fldiff that will find the diff between
  # the latest filter list, and any number of previous filter lists.
  # from: https://gitlab.com/eyeo/auxiliary/python-abp
  ensure_resource('package', ['python-abp'], {
    ensure => '0.1.2',
    provider => 'pip',
    require => Package['python-pip'],
  })

  $data_directory = '/home/rsync/generated/data'
  $archive_directory = "${data_directory}/archive"
  $diff_directory = "${data_directory}/diff"

  $base_directories = [
    $data_directory,
    $archive_directory,
    $diff_directory,
  ]

  ensure_resource('file', $base_directories, {
    ensure => ensure_directory_state($ensure),
    owner => 'rsync',
  })

  create_resources('filtermaster::iflu::filterlist', $filterlists)
}
