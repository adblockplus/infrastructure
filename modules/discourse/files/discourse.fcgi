#!/usr/bin/ruby

Dir.chdir(File.dirname(__FILE__))
ENV['RAILS_ENV'] ||= 'production'
ENV['GEM_HOME'] = File.expand_path('~discourse/.gems')
ENV['GEM_PATH'] = File.expand_path('~discourse/.gems') + ':/var/lib/gems/1.9.1'

require 'fcgi'
require_relative 'config/environment'

class Rack::PathInfoRewriter
  def initialize(app)
    @app = app
  end

  def call(env)
    env.delete('SCRIPT_NAME')
    parts = env['REQUEST_URI'].split('?')
    env['PATH_INFO'] = parts[0]
    env['QUERY_STRING'] = parts[1].to_s
    @app.call(env)
  end
end

Rack::Handler::FastCGI.run Rack::PathInfoRewriter.new(Discourse::Application)
