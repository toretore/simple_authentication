ActionController::Routing::Routes.draw do |map|
  map.resource :login
  map.new_login_with_authenticator 'login/:authenticator', :controller => 'logins', :action => 'new'
end
