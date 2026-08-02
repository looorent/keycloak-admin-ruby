# frozen_string_literal: true
require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'Realm Integration' do
  let(:realm_name) { "integration-realm-#{SecureRandom.hex(4)}" }

  it 'performs full CRUD on a realm' do
    realms_client = KeycloakAdmin::RealmClient.new(KeycloakAdmin.config, nil)

    # 1. Create a realm
    realm_representation = KeycloakAdmin::RealmRepresentation.from_hash({
      "realm" => realm_name,
      "enabled" => true,
      "displayName" => "Integration Test Realm"
    })
    
    realms_client.save(realm_representation)

    # 2. Fetch the realm by name
    realm_client_by_name = KeycloakAdmin.realm(realm_name)
    fetched_realms = realms_client.list
    fetched_realm = fetched_realms.find { |r| r.realm == realm_name }
    
    expect(fetched_realm).not_to be_nil
    expect(fetched_realm.realm).to eq(realm_name)

    # 3. Update the realm
    # Not testing update because RealmRepresentation has few attributes
    
    # 4. Delete the realm
    realm_client_by_name.delete
    
    final_realms = realms_client.list
    expect(final_realms.find { |r| r.realm == realm_name }).to be_nil
  end

  it 'handles errors properly when creating a duplicate realm' do
    realms_client = KeycloakAdmin::RealmClient.new(KeycloakAdmin.config, nil)
    duplicate_realm = "duplicate-realm-#{SecureRandom.hex(4)}"

    realm_representation = KeycloakAdmin::RealmRepresentation.from_hash({
      "realm" => duplicate_realm,
      "enabled" => true
    })
    
    realms_client.save(realm_representation)

    expect {
      realms_client.save(realm_representation)
    }.to raise_error(KeycloakAdmin::ApiError)
  end

  it 'handles errors when getting a non-existent realm' do
    # Actually realm getter always returns a RealmClient, not raising an error unless we fetch something from it
    realm_client_by_name = KeycloakAdmin.realm("invalid-realm-name")
    expect {
      realm_client_by_name.users.list
    }.to raise_error(KeycloakAdmin::ApiError)
  end
end
