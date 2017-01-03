# coding: utf-8
# vi: set fenc=utf-8 ft=ruby ts=8 sw=2 sts=2 et:
module Puppet::Parser::Functions

  newfunction(:ensure_file_state, :type => :rvalue, :doc => <<-'begin') do |args|
    Returns "present" if ensure_state() for the given parameter evaluates to
    true, return "absent" otherwise.
  begin
    result = function_ensure_state(args) ? 'present' : 'absent'
    return result
  end

end
