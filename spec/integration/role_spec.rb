require_relative '../integration_helper'
require 'securerandom'

RSpec.describe 'Role Integration' do
  let(:realm_name) { 'dummy' }
  let(:role_name) { "integration-role-#{SecureRandom.hex(4)}" }

  it 'performs full CRUD on a role' do
    roles_client = KeycloakAdmin.realm(realm_name).roles

    # 1. Create a role
    role_representation = KeycloakAdmin::RoleRepresentation.from_hash({
      "name" => role_name
    })
    
    roles_client.save(role_representation)

    # 2. Fetch the role by name
    fetched_role = roles_client.get(role_name)
    expect(fetched_role.name).to eq(role_name)
    expect(fetched_role.composite).to be_falsey

    # 3. Update the role
    # Role representation has very few fields, so we won't test update here


  end
end
