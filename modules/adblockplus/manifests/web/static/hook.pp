# == Type: adblockplus::web::static::hook
#
# Manage custom hooks to be triggered via ssh commands
#
# === Parameters:
#
# [*file*]
#   Overwrite group and the source of the content of the file.
#
# === Examples:
#
#  adblockplus::web::static::hook {'deploy':
#    file => {
#      source => 'puppet:///modules/adblockplus/web/deploy.py',
#      path => '/usr/local/bin/deploy.py',
#    },
#   }
#
#  adblockplus::web::static::hook {'uname':
#    file => {
#      content => 'uname -a',
#    },
#  }
#
#  adblockplus::web::static::hook {'uptime':
#    file => {
#      target => '/usr/bin/uptime',
#      ensure => 'link',
#    },
#  }
#
define adblockplus::web::static::hook (
  $file,
) {

  $hook_path = "/home/${adblockplus::web::static::deploy_user}/bin/${name}"

  ensure_resource('file', "web-deploy-hook#${title}", merge({
    group => $adblockplus::web::static::deploy_user,
    ensure => ensure_file_state($adblockplus::web::static::ensure),
  }, $file, {
    mode => '0755',
    owner => $adblockplus::web::static::deploy_user,
    path => $hook_path,
  }))
}

