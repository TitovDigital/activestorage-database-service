$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "activestorage/database/service/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activestorage-database-service"
  s.version     = Activestorage::Database::Service::VERSION
  s.authors     = ["Pavel Titov"]
  s.email       = ["pavel@titovdigital.com"]
  s.homepage    = "https://github.com/TitovDigital/"
  s.summary     = "ActiveStorage database service to store binary files in a database."
  s.description = "ActiveStorage database service to store binary files in a database."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.2.1.1"

  s.add_development_dependency "pg"
end
