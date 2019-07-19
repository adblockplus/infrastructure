# == Type: filtermaster::iflu::filterlist
#
# Manage resrouces associated to a specific filter list in the
# incremental updates context.
#
# === Parameters:
#
# [*cron*]
#   Default options for Cron['filtermaster::iflu::filterlist'], e.g. $minute,
#   $monthday etc.
#
# [*ensure*]
#   General resource policy, i.e. "present" or "absent".
#
# [*hook*]
#
#  A command to execute when Cron['filtermaster::iflu::filterlist'] has
#  succeeded, optional.
#
define filtermaster::iflu::filterlist (
  $cron = {},
  $ensure = 'present',
  $hook = undef,
) {

  Cron {
    environment => concat(hiera('cron::environment', []), [
      'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    ]),
  }

  $archive_directory = "$filtermaster::iflu::archive_directory/$title"
  $diff_directory = "$filtermaster::iflu::diff_directory/$title"

  $directories = [
    $archive_directory,
    $diff_directory,
  ]

  ensure_resource('file', $directories, {
    ensure => ensure_directory_state($ensure),
    owner => 'rsync',
  })

  # According to the specification of incremental filter lists updates, the
  # diffs should be up to two days and no more. For more info see:
  # https://gitlab.com/eyeo/auxiliary/python-abp/wikis/iflu-0.1
  $script = join([
    "cd ${filtermaster::iflu::data_directory}",
    "cp ${title}.txt $(date +${archive_directory}/${title}_\\%d_\\%m_\\%Y_\\%H_\\%M.txt)",
    "find ${archive_directory} -type f -mmin +2880 -delete",
    "find ${diff_directory}/ -type f -delete",
    "fldiff -o ${diff_directory} ${title}.txt ${archive_directory}/*",
  ], '&&')

  ensure_resource('cron', {"iflu#$title" => $cron}, merge({
    command => $hook ? {undef => $script, default => "$script && $hook"},
    ensure => $ensure,
    hour => '*/1',
    minute => 0,
    user => 'rsync',
  }, $cron))

}
