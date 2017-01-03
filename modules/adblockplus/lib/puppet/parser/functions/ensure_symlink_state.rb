# coding: utf-8
# vi: set fenc=utf-8 ft=ruby ts=8 sw=2 sts=2 et:
module Puppet::Parser::Functions

  newfunction(:ensure_symlink_state, :type => :rvalue, :doc => <<-'begin') do |args|
    Returns "link" if ensure_state() for the given parameter evaluates to
    true, return "absent" otherwise.
  begin
    result = function_ensure_state(args) ? 'link' : 'absent'
    return result
  end

end
