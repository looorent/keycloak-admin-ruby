$:.push File.expand_path("../lib", __FILE__)

require "keycloak-admin/version"

Gem::Specification.new do |spec|
  spec.name        = "keycloak-admin"
  spec.version     = KeycloakAdmin::VERSION
  spec.authors     = ["Lorent Lempereur"]
  spec.email       = ["lorent.lempereur.dev@gmail.com"]
  spec.homepage    = "https://github.com/looorent/keycloak-admin-ruby"
  spec.summary     = "Keycloak Admin REST API client written in Ruby"
  spec.description = "Keycloak Admin REST API client written in Ruby"
  spec.license     = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency "http-cookie", "~> 1.0", ">= 1.0.3"
  spec.add_dependency "rest-client", "~> 2.0"
  spec.add_development_dependency "rspec",  "3.12.0"
  spec.add_development_dependency "byebug", "11.1.3"
end
