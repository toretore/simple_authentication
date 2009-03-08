require "simple_authentication/authenticator"
require "simple_authentication/controller_methods"
require "simple_authentication/model_methods"

ApplicationController.send(:include, SimpleAuthentication::ControllerMethods::Application)
I18n.load_path << File.join(File.dirname(__FILE__), '..', 'config', 'locales', 'simple_authentication.yml')
