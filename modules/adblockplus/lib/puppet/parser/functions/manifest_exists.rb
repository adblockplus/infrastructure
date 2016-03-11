module Puppet::Parser::Functions

  newfunction(:manifest_exists, :type => :rvalue, :doc => <<-'begin') do |args|
    Determine if a Puppet manifest (*.pp file) exists for the given type name,
    within the Puppet hierarchy of the (adblockplus) module's parent directory
  begin

    if args.size != 1
      message = "Usage: manifest_exists('some::definition::name')"
      raise Puppet::ParseError, message
    end

    # 'foo::bar::baz' => 'foo', ['bar', 'baz']
    module_name, *remainder = args[0].to_s.split('::')

    base_directory = File.expand_path(File.join(
      File.dirname(__FILE__),
      '..', # parser
      '..', # puppet
      '..', # lib
      '..', # $module
      '..' # modules
    ))

    manifest_path = File.join(
      base_directory,
      module_name,
      'manifests',
      File.join(*remainder) << '.pp'
    )

    return File.exists? manifest_path

  end
end
