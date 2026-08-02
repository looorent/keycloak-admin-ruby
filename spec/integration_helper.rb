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

    # Enable internationalization in the dummy realm.
    # Since Keycloak 24 the "locale" user attribute is a reserved one, only persisted when
    # the realm supports internationalization. Done through an update so it also applies to
    # a realm left over by a previous run.
    conn.put("/admin/realms/dummy") do |req|
      req.headers['Authorization'] = "Bearer #{token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        realm: 'dummy',
        internationalizationEnabled: true,
        supportedLocales: ["en"],
        defaultLocale: "en"
      }.to_json
    end

    # Allow unmanaged user attributes in the dummy realm.
    # Since Keycloak 24 the declarative user profile is always enabled, and unmanaged
    # attributes are rejected by default: any attribute not declared in the profile
    # (locale, custom ones) is silently dropped on write and never read back.
    # Older versions do not expose this endpoint, hence the best-effort handling.
    profile_response = conn.get("/admin/realms/dummy/users/profile") do |req|
      req.headers['Authorization'] = "Bearer #{token}"
    end
    if profile_response.status == 200 && profile_response.body.is_a?(Hash)
      conn.put("/admin/realms/dummy/users/profile") do |req|
        req.headers['Authorization'] = "Bearer #{token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = profile_response.body.merge("unmanagedAttributePolicy" => "ENABLED").to_json
      end
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
