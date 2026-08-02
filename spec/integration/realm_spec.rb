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
end
