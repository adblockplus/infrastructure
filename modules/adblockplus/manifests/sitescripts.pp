# A namespace for sitescripts-related classes and named types, see
# http://hub.eyeo.com/issues/5944 for context and background information
class adblockplus::sitescripts {

  # http://hub.eyeo.com/issues/5944#note-9
  $repositories = hiera('adblockplus::sitescripts::repositories', {})
  ensure_resources('adblockplus::sitescripts::repository', $repositories)

  # http://hub.eyeo.com/issues/5979
  include ::sitescripts
}
