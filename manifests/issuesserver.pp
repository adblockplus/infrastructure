node 'issues1' {
  include base

  class {'roundup':
    tracker_name => 'adblockplus',
    domain => 'issues.adblockplus.org'
  }
}
