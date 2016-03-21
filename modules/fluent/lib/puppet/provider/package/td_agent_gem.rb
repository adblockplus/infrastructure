require 'puppet/provider/package/gem'
require 'puppet/type'

# modules/fluent/lib/puppet/provider/package/fluent_gem.rb
Puppet::Type.type(:package).provide :td_agent_gem, :parent => :fluent_gem do

  # http://docs.fluentd.org/articles/plugin-management#if-using-td-agent-use-usrsbintd-agent-gem
  desc 'Ruby Gem support for Fluentd packages, via td-agent-gem'
  commands :gemcmd => 'td-agent-gem'

end
