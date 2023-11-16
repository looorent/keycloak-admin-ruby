require_relative "../lib/keycloak-admin"

require "byebug"

def configure
  KeycloakAdmin.configure do |config|
    config.server_url          = "http://auth.service.io/auth"
    config.server_domain       = "auth.service.io"
    config.client_id           = "admin-cli"
    config.client_secret       = "aaaaaaaa"
    config.client_realm_name   = "master2"
    config.use_service_account = true
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  configure
end

def stub_token_client
  allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get).and_return KeycloakAdmin::TokenRepresentation.new(
    "test_access_token", "token_type", "expires_in", "refresh_token",
    "refresh_expires_in", "id_token", "not_before_policy", "session_state"
  )
end

def stub_net_http_res(res_class, code, message)
  net_http_res = double(message:  message, code: code)
  allow(net_http_res).to receive(:is_a?) do |target_class|
    target_class == res_class
  end
  allow(@response).to receive(:net_http_res).and_return(net_http_res)
end
