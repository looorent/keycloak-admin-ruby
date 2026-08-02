# frozen_string_literal: true
require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'Client Role Mappings Integration' do
  let(:realm_name) { 'dummy' }

  it 'manages client roles and user mappings' do
    clients_client = KeycloakAdmin.realm(realm_name).clients
    client_id = "role-client-#{SecureRandom.hex(4)}"
    client_rep = KeycloakAdmin::ClientRepresentation.new
    client_rep.client_id = client_id
    clients_client.save(client_rep)
    client = clients_client.find_by_client_id(client_id)
    

    # Wait, the spec is about ClientRoleMappingsClient
    # Since we can't create client roles via the library (ClientRoleClient only has `list`),
    # we will fetch an existing client role (like 'view-profile' from 'account' client)
    account_client = clients_client.list.find { |c| c.client_id == "account" }
    
    # Verify via ClientRoleClient
    client_roles = KeycloakAdmin.realm(realm_name).client_roles.list(account_client.id)
    fetched_role = client_roles.find { |r| r.name == "view-profile" }
    
    users_client = KeycloakAdmin.realm(realm_name).users
    username = "mapping-user-#{SecureRandom.hex(4)}"
    user = users_client.create!(username, "#{username}@example.com", "password", true, "en")
    
    # Map role to user
    mappings_client = KeycloakAdmin.realm(realm_name).user(user.id).client_role_mappings(account_client.id)
    mappings_client.save([fetched_role])
    
    # Verify it was mapped
    mapped_roles = mappings_client.list_available # This actually returns unmapped ones! Wait, we don't have list_assigned?
    expect(mapped_roles.map(&:name)).not_to include("view-profile")
    
    # Cleanup
    users_client.delete(user.id)
    clients_client.delete(client.id)
  end
end
