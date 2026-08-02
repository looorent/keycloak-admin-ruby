# frozen_string_literal: true
require_relative "../lib/keycloak-admin"

require "byebug"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

def configure
  KeycloakAdmin.configure do |config|
    config.server_url          = "http://auth.service.io/auth"
    config.server_domain       = "auth.service.io"
    config.client_id           = "admin-cli"
    config.client_secret       = "aaaaaaaa"
    config.client_realm_name   = "master2"
    config.use_service_account = true
    config.logger              = ::Logger.new(IO::NULL)
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  configure

  config.before(:each) do
    KeycloakAdmin.config.clear_cached_token!
  end
end

def stub_token_client
  allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get).and_return KeycloakAdmin::TokenRepresentation.new(
    "test_access_token", "token_type", 3600, "refresh_token",
    "refresh_expires_in", "id_token", "not_before_policy", "session_state"
  )
end
