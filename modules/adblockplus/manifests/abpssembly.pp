# Manage the setup of abpssembly, a fork of sitescripts specific to the
# Adblock Plus extension builds and similar.
class adblockplus::abpssembly {

  # http://hub.eyeo.com/issues/5876
  include nodejs

  # http://hub.eyeo.com/issues/5944
  ensure_resource('adblockplus::sitescripts::repository', 'abpssembly')
}
