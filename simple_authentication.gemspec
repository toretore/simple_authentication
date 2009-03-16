Gem::Specification.new do |s|
  s.name     = "simple_authentication"
  s.version  = "0.1.2"
  s.date     = "2009-03-16"
  s.summary  = "Authentication, simple"
  s.email    = "toredarell@gmail.com"
  s.homepage = "http://github.com/toretore/simple_authentication"
  s.description = "Simple authentication"
  #s.has_rdoc = true
  s.author  = "Tore Darell"
  #s.files   = Dir["lib/**/*"] + Dir["rails/**/*"] + Dir["config/**/*"] + Dir["app/**/*"] + Dir["generators/**/*"] + Dir["tasks/**/*"]
  s.files   = %w(lib/simple_authentication.rb lib/simple_authentication lib/simple_authentication/authenticator.rb lib/simple_authentication/controller_methods.rb lib/simple_authentication/model_methods.rb rails/uninstall.rb rails/install.rb rails/init.rb config/routes.rb config/locales config/locales/simple_authentication.yml app/views app/views/logins app/views/logins/new.html.erb app/views/logins/show.html.erb app/controllers app/controllers/logins_controller.rb app/models app/models/user.rb generators/simple_authentication generators/simple_authentication/simple_authentication_generator.rb generators/simple_authentication/USAGE generators/simple_authentication/templates tasks/simple_authentication_tasks.rake)
  #s.rdoc_options = ["--main", "README.txt"]
  #s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  #s.add_dependency("simple_authentication", [">= 0.1.0"])
end
