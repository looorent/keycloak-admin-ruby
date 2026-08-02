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

  spec.files         = Dir.glob(["lib/**/*.rb", "CHANGELOG.md", "MIT-LICENSE", "README.md", "keycloak-admin.gemspec"]).sort
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "source_code_uri"       => spec.homepage,
    "changelog_uri"         => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri"       => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.add_dependency "http-cookie", "~> 1.0", ">= 1.0.3"
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "base64"
  spec.add_development_dependency "rspec",   "3.13.2"
  spec.add_development_dependency "byebug",  "12.0.0"
  spec.add_development_dependency "rake",    ">= 13.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "bundler-audit", "~> 0.9"
end