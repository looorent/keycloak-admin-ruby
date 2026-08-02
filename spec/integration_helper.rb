# frozen_string_literal: true
require_relative 'spec_helper'
require 'faraday'
require 'json'

WebMock.allow_net_connect!

RSpec.configure do |config|
  config.before(:suite) do
    KeycloakAdmin.configure do |c|
      c.use_service_account = false
      c.server_url          = "http://localhost:8080"
      c.server_domain       = "localhost:8080"
      c.client_id           = "admin-cli"
      c.client_realm_name   = "master"
      c.username            = "admin"
      c.password            = "admin"
      c.faraday_options     = { request: { timeout: 10 }, ssl: { verify: false } }
    end
    
    # Try to wait for keycloak
    30.times do
      begin
        response = Faraday.get("http://localhost:8080/realms/master")
        break if response.status == 200
      rescue Faraday::ConnectionFailed
        # ignore
      end
      sleep 1
    end

    # Get admin token
    conn = Faraday.new(url: "http://localhost:8080") do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
    
    token_response = conn.post("/realms/master/protocol/openid-connect/token") do |req|
      req.body = {
        grant_type: 'password',
        username: 'admin',
        password: 'admin',
        client_id: 'admin-cli'
      }
    end
    token = token_response.body['access_token']

    # Use a new connection for JSON requests
    conn = Faraday.new(url: "http://localhost:8080") do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end

    # Create realm dummy
    conn.post("/admin/realms") do |req|
      req.headers['Authorization'] = "Bearer #{token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = { realm: 'dummy', enabled: true }.to_json
    end

    # Create dummy-client in dummy realm
    conn.post("/admin/realms/dummy/clients") do |req|
      req.headers['Authorization'] = "Bearer #{token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        clientId: "dummy-client",
        enabled: true,
        consentRequired: false,
        attributes: {},
        serviceAccountsEnabled: true,
        protocol: "openid-connect",
        publicClient: false,
        authorizationServicesEnabled: true,
        clientAuthenticatorType: "client-secret",
        redirectUris: ["http://localhost:8180/demo"]
      }.to_json
    end
  end

  config.after(:suite) do
    configure # Reset to default mock config
  end
end
