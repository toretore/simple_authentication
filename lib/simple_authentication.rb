require "simple_authentication/authenticator"
require "simple_authentication/controller_methods"
require "simple_authentication/model_methods"

ApplicationController.send(:include, SimpleAuthentication::ControllerMethods::Application)
