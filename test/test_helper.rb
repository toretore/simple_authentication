require 'rubygems'
require 'test/unit'

#Use vendored rails
Dir[File.dirname(__FILE__)+'/../../../rails/*/lib'].each{|lib| $: << lib }

require 'action_controller'
require 'active_record'

%w(controllers models).each{|s| $: << File.join(File.dirname(__FILE__), '..', 'app', s) }

ActionController::Base.view_paths << File.join(File.dirname(__FILE__), '..', 'app', 'views')

class ApplicationController < ActionController::Base
end

require 'simple_authentication'

def load_routes(&b)
  ActionController::Routing::Routes.configuration_files << File.join(File.dirname(__FILE__), '..', 'config', 'routes.rb')
  ActionController::Routing::Routes.load!
  ActionController::Routing::Routes.draw(&b) if block_given?
end

def load_schema
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

  require 'sqlite3'

  ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => File.join(File.dirname(__FILE__), 'test.sqlite3')})
  load(File.dirname(__FILE__) + "/schema.rb")
end
