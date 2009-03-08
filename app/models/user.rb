class User < ActiveRecord::Base

  include SimpleAuthentication::ModelMethods::User

end
