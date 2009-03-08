class LoginsController < ApplicationController

  include SimpleAuthentication::ControllerMethods::Logins
  include SimpleAuthentication::ControllerMethods::Logins::Behavior

end
