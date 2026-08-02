# frozen_string_literal: true
require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'Role Mapper Integration' do
  let(:realm_name) { "dummy" }

  it 'adds and removes role mappings for a user' do
    users_client = KeycloakAdmin.realm(realm_name).users
    roles_client = KeycloakAdmin.realm(realm_name).roles

    username = "rolemapper-user-#{SecureRandom.hex(4)}"
    created_user = users_client.create!(username, "#{username}@example.com", "password", true, "en")

    role_name = "rolemapper-role-#{SecureRandom.hex(4)}"
    role_representation = KeycloakAdmin::RoleRepresentation.new
    role_representation.name = role_name
    roles_client.save(role_representation)

    role_mapper_client = KeycloakAdmin.realm(realm_name).user(created_user.id).role_mapper
    fetched_role = roles_client.get(role_name)

    # Add realm level role
    role_mapper_client.save_realm_level([fetched_role])

    # List
    mappings = role_mapper_client.list
    expect(mappings.map(&:name)).to include(role_name)

    # Remove
    role_mapper_client.remove_realm_level([fetched_role])
    
    # List again
    mappings_after = role_mapper_client.list
    expect(mappings_after.map(&:name)).not_to include(role_name)

    # Cleanup
    users_client.delete(created_user.id)
  end
end
