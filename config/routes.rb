ActionController::Routing::Routes.draw do |map|
  map.new_login_with_authenticator 'login/:authenticator', :controller => 'logins', :action => 'new'
  map.resource :login
end
