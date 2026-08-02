# frozen_string_literal: true
require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'Group Integration' do
  let(:realm_name) { 'dummy' }
  let(:group_name) { "integration-group-#{SecureRandom.hex(4)}" }

  it 'performs full CRUD on a group' do
    groups_client = KeycloakAdmin.realm(realm_name).groups

    # 1. Create a group
    group_representation = KeycloakAdmin::GroupRepresentation.new
    group_representation.name = group_name
    group_representation.path = "/#{group_name}"
    group_representation.attributes = { "department" => ["IT"] }
    
    created_id = groups_client.create!(group_representation.name, group_representation.path, group_representation.attributes)
    expect(created_id).not_to be_nil

    # 2. Fetch the group by ID
    fetched_group = groups_client.get(created_id)
    expect(fetched_group.id).to eq(created_id)
    expect(fetched_group.name).to eq(group_name)
    expect(fetched_group.path).to eq("/#{group_name}")
    expect(fetched_group.attributes[:department]).to include("IT")

    # 3. Update the group
    fetched_group.name = "#{group_name}-updated"
    fetched_group.remove_instance_variable(:@sub_group_count) if fetched_group.instance_variable_defined?(:@sub_group_count)
    groups_client.save(fetched_group)

    updated_group = groups_client.get(created_id)
    expect(updated_group.name).to eq("#{group_name}-updated")

    # 4. Delete the group
    groups_client.delete(created_id)
    
    expect {
      groups_client.get(created_id)
    }.to raise_error(KeycloakAdmin::ApiError)
  end

  it 'handles errors when creating a group without a name' do
    groups_client = KeycloakAdmin.realm(realm_name).groups
    expect {
      groups_client.create!(nil)
    }.to raise_error(KeycloakAdmin::ApiError)
  end

  it 'handles errors when getting a non-existent group' do
    groups_client = KeycloakAdmin.realm(realm_name).groups
    expect {
      groups_client.get("invalid-uuid-1234")
    }.to raise_error(KeycloakAdmin::ApiError)
  end
end
