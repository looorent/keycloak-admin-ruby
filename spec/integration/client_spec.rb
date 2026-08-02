# frozen_string_literal: true
require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'Client Integration' do
  let(:realm_name) { 'dummy' }
  let(:client_id) { "integration-client-#{SecureRandom.hex(4)}" }

  it 'performs full CRUD on a client' do
    clients_client = KeycloakAdmin.realm(realm_name).clients

    # 1. Create a client
    client_representation = KeycloakAdmin::ClientRepresentation.new
    client_representation.client_id = client_id
    client_representation.description = "Integration Test Client"
    client_representation.redirect_uris = ["http://localhost:8080/*"]
    client_representation.standard_flow_enabled = true
    client_representation.public_client = true
    client_representation.root_url = "http://localhost:8080"
    
    clients_client.save(client_representation)
    
    fetched_client = clients_client.find_by_client_id(client_id)
    expect(fetched_client).not_to be_nil

    # 2. Fetch the client by ID
    fetched_client = clients_client.get(fetched_client.id)
    expect(fetched_client.id).not_to be_nil
    expect(fetched_client.client_id).to eq(client_id)
    expect(fetched_client.description).to eq("Integration Test Client")
    expect(fetched_client.redirect_uris).to include("http://localhost:8080/*")
    expect(fetched_client.standard_flow_enabled).to be_truthy
    expect(fetched_client.public_client).to be_truthy
    expect(fetched_client.root_url).to eq("http://localhost:8080")

    # 3. Update the client
    fetched_client.description = "Updated Integration Test Client"
    updated_client = clients_client.update(fetched_client)

    updated_client = clients_client.get(fetched_client.id)
    expect(updated_client.description).to eq("Updated Integration Test Client")

    # 4. Delete the client
    clients_client.delete(fetched_client.id)
    
    expect {
      clients_client.get(fetched_client.id)
    }.to raise_error(KeycloakAdmin::ApiError)
  end

  it 'handles errors properly when creating a duplicate client' do
    clients_client = KeycloakAdmin.realm(realm_name).clients
    duplicate_client_id = "duplicate-client-#{SecureRandom.hex(4)}"

    client_representation = KeycloakAdmin::ClientRepresentation.new
    client_representation.client_id = duplicate_client_id
    clients_client.save(client_representation)

    # Creating a second one with the same client_id should raise ConflictError or ApiError
    expect {
      clients_client.save(client_representation)
    }.to raise_error(KeycloakAdmin::ApiError)
  end

  it 'handles errors when getting a non-existent client' do
    clients_client = KeycloakAdmin.realm(realm_name).clients
    expect {
      clients_client.get("invalid-uuid-1234")
    }.to raise_error(KeycloakAdmin::ApiError)
  end
end
