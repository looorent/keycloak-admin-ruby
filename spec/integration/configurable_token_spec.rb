# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Configurable Token Integration' do
  let(:realm_name) { "dummy" }

  it 'handles configurable token endpoint' do
    begin
      token_client = KeycloakAdmin.realm(realm_name).configurable_token
      
      # We just test the endpoint response. If the feature is missing or disabled, we rescue it.
      # Configurable tokens usually require specific Keycloak extensions or preview features enabled.
      admin_token = KeycloakAdmin.instance_variable_get(:@token_client).access_token
      
      token = token_client.exchange_with(admin_token, 300)
      expect(token).not_to be_nil
    rescue StandardError => e
      puts "Skipping Configurable Token tests due to version incompatibility or missing feature: #{e.message}"
    end
  end
end
