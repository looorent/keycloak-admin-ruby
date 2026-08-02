require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'User Integration' do
  let(:realm_name) { 'dummy' }
  let(:username) { "integration-user-#{SecureRandom.hex(4)}" }

  it 'performs full CRUD on a user' do
    users_client = KeycloakAdmin.realm(realm_name).users

    # 1. Create a user
    created_user = users_client.create!(
      username, 
      "#{username}@example.com", 
      "password", 
      true, # email_verified
      "en", # locale
      { "customAttr" => "value1" } # attributes
    )
    expect(created_user).not_to be_nil
    expect(created_user.id).not_to be_nil

    # 2. Fetch the user by username
    search_results = users_client.search(username)
    expect(search_results.length).to eq(1)
    fetched_user = search_results.first
    expect(fetched_user.id).to eq(created_user.id)
    expect(fetched_user.email).to eq("#{username}@example.com")
    expect(fetched_user.email_verified).to be_truthy
    expect(fetched_user.attributes["locale"]).to include("en")
    expect(fetched_user.attributes["customAttr"]).to include("value1")

    # 3. Fetch the user by ID
    user_by_id = users_client.get(created_user.id)
    expect(user_by_id.id).to eq(created_user.id)

    # 4. Update the user
    user_by_id.first_name = "Updated Integration"
    users_client.update(created_user.id, user_by_id)

    updated_user = users_client.get(created_user.id)
    expect(updated_user.first_name).to eq("Updated Integration")

    # 5. Delete the user
    users_client.delete(created_user.id)
    
    expect {
      users_client.get(created_user.id)
    }.to raise_error(KeycloakAdmin::ApiError)
  end

  it 'handles errors properly when creating a duplicate user' do
    users_client = KeycloakAdmin.realm(realm_name).users
    duplicate_username = "duplicate-#{SecureRandom.hex(4)}"

    # Create first time
    users_client.create!(duplicate_username, "#{duplicate_username}@example.com", "password", true, "en")

    # Create second time
    expect {
      users_client.create!(duplicate_username, "#{duplicate_username}@example.com", "password", true, "en")
    }.to raise_error(KeycloakAdmin::ApiError) # Or ConflictError depending on library wrapping
  end

  it 'handles errors when getting a non-existent user' do
    users_client = KeycloakAdmin.realm(realm_name).users
    expect {
      users_client.get("invalid-uuid-1234")
    }.to raise_error(KeycloakAdmin::ApiError)
  end
end
