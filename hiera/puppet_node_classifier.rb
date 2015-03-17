#!/usr/bin/env ruby
# This script is a node classifier for Puppet that operates on top of Hiera
# and uses a custom hosts.yaml config to map host roles.

require 'getoptlong'
require 'hiera'
require 'socket'
require 'yaml'

# Where to search for the Hiera configuration
HIERA_CONFIG = ENV.fetch('PUPPET_HIERA_CONFIG', '/etc/puppet/hiera.yaml')
# Where to search for the Hosts configuration
HOSTS_CONFIG = ENV.fetch('PUPPET_HOSTS_CONFIG', '/etc/puppet/infrastructure/hiera/private/hosts.yaml')

# For logging and usage hints
BASENAME = File.basename($0)

# There's no need for any options beside the commonly exepected ones yet
GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT]
).each do |opt, arg|
  case opt

    when '--help'
      puts <<-END
Usage:  #{BASENAME} [hostname]
        #{BASENAME} example.com
        #{BASENAME} --help

Options:

    --help, -h
        Display this help message and exit gracefully.

Environment:

    PUPPET_HIERA_CONFIG=#{HIERA_CONFIG}
        Where to find the hiera configuration file.
    PUPPET_HOSTS_CONFIG=#{HOSTS_CONFIG}
        Where to find the hosts configuration file.

END
      exit 0

  end
end

# Only one additional non-option argument is allowed, in order to explicitly
# specify a hostname to use instead of the default:
case ARGV.length
  when 0
    hostname = Socket.gethostname
  when 1
    hostname = ARGV[0][/^[^.]+/]
  else
    STDERR.puts <<-END
#{BASENAME}: unknown option: #{ARGV[0]}
#{BASENAME}: try #{BASENAME} --help
END
    exit 1
end

# Extract the server -> hostname -> role information from the hosts
# configuration file:
begin
  config = YAML.load_file(HOSTS_CONFIG)
  servers = config.fetch("servers", {})
  host = servers.fetch(hostname, {})
  role = host.fetch("role", "default")
rescue Exception => error
  STDERR.puts "#{BASENAME}: #{error.message}: #{HOSTS_CONFIG}"
  exit 1
end

# Map Hiera data into the structure Puppet expects an ENC to generate (see
# https://docs.puppetlabs.com/guides/external_nodes.html for more info):
begin
  hiera = Hiera.new(:config => HIERA_CONFIG)
  scope = {'::hostname' => hostname, '::role' => role}
  classes = hiera.lookup('classes', {}, scope, nil, :hash)
  parameters = hiera.lookup('parameters', {}, scope, nil, :hash)
  parameters['role'] = role
  result = { 'classes' => classes, 'parameters' => parameters }
rescue Exception => error
  STDERR.puts "#{BASENAME}: #{error.message}: #{HIERA_CONFIG}"
  exit 1
end

puts result.to_yaml

