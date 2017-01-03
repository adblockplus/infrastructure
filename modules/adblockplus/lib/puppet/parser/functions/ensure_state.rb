# coding: utf-8
# vi: set fenc=utf-8 ft=ruby ts=8 sw=2 sts=2 et:
module Puppet::Parser::Functions

  newfunction(:ensure_state, :type => :rvalue, :doc => <<-'begin') do |args|
    Returns true if the given parameter does not match any keyword commonly
    associated with absence, false otherwise.
  begin

    usage = 'Usage: ensure_state($resource_or_string)'
    raise Puppet::ParseError, usage unless args.size == 1

    if args[0].nil?
      result = false
    else

      if args[0].is_a? String
        value = args[0]
      elsif resource = findresource(args[0].to_s)
        value = resource['ensure'].to_s
      else
        raise Puppet::ParseError, usage
      end

      if value.match(/^(absent|false|purged|stopped)$/)
        result = false
      else
        result = true
      end

    end

    return result

  end

end
