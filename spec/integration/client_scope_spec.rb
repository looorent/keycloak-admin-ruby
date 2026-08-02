# frozen_string_literal: true
require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'Client Scope Integration' do
  let(:realm_name) { 'dummy' }

  it 'performs CRUD on client scope and protocol mappers' do
    client_scopes_client = KeycloakAdmin.realm(realm_name).client_scopes
    scope_name = "integration-scope-#{SecureRandom.hex(4)}"

    # 1. Create client scope
    scope_rep = KeycloakAdmin::ClientScopeRepresentation.new
    scope_rep.name = scope_name
    scope_rep.protocol = "openid-connect"
    
    client_scopes_client.create!(scope_rep)
    
    # 2. Find it via search
    fetched_scope = client_scopes_client.search(scope_name).first
    expect(fetched_scope).not_to be_nil
    
    # 3. Protocol Mapper
    mapper_client = KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(fetched_scope.id)
    mapper_rep = KeycloakAdmin::ProtocolMapperRepresentation.new
    mapper_rep.name = "dummy-mapper"
    mapper_rep.protocol = "openid-connect"
    mapper_rep.protocolMapper = "oidc-audience-mapper"
    mapper_rep.config = {
      "included.client.audience" => "some-client",
      "id.token.claim" => "false",
      "access.token.claim" => "true"
    }
    
    mapper_client.create!(mapper_rep)
    
    mappers = mapper_client.list
    fetched_mapper = mappers.find { |m| m.name == "dummy-mapper" }
    expect(fetched_mapper).not_to be_nil
    
    mapper_client.delete(fetched_mapper.id)
    
    # 4. Delete client scope
    client_scopes_client.delete(fetched_scope.id)
  end
end
