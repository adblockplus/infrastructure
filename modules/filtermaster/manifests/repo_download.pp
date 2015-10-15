# == Type: filtermaster::repo_download
#
# Manage filter list download source repositories for aggregation.
#
# === Parameters:
#
# [*target*]
#   An optional alias for use as the download resource name, allows for
#   repositories with different names. Note that this option is recognized
#   only when setup via hiera('filtermaster::repo_downloads')!
#
# [*static_files*]
#   Files to include in the synchronization of download resources without
#   prior aggregation, if any. Note that option is recognized only when
#   setup via hiera('filtermaster::repo_downloads') as well!
#
# === Examples:
#
#   filtermaster::repo_download {'exceptionrules':
#     alias => 'exceptions',
#   }
#
define filtermaster::repo_download (
  $target = $title,
  $static_files = [],
) {

  $directory = "/home/rsync/subscription/$title"
  $repository = "https://hg.adblockplus.org/$title"

  ensure_packages(['mercurial'])

  exec {"filtermaster::repo_download#$title":
    command => shellquote('hg', 'clone', $repository, $directory),
    onlyif => shellquote('test', '!', '-d', $directory),
    path => ['/usr/local/bin', '/usr/bin', '/bin'],
    require => Package['mercurial'],
    timeout => 0,
    user => 'rsync',
  }

  file {"$directory/.hg/hgrc":
    content => template('filtermaster/hgrc.erb'),
    owner => 'rsync',
    require => Exec["filtermaster::repo_download#$title"],
  }
}
