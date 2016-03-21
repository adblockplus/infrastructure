require 'puppet/provider/package/gem'
require 'puppet/type'

# http://docs.puppetlabs.com/puppet/latest/reference/type.html#package-provider-gem
Puppet::Type.type(:package).provide :fluent_gem, :parent => :gem do

  # http://docs.fluentd.org/articles/plugin-management#fluent-gem
  desc 'Ruby Gem support for Fluentd packages, via fluent-gem'
  commands :gemcmd => 'fluent-gem'

  # https://projects.puppetlabs.com/issues/19663
  def execute(command, arguments = {:failonfail => true, :combine => true})
    command.delete('--include-dependencies')
    super
  end

end
