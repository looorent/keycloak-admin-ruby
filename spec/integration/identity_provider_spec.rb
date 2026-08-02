# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Identity Provider Integration' do
  let(:realm_name) { "dummy" }

  it 'performs CRUD on an identity provider' do
    idp_client = KeycloakAdmin.realm(realm_name).identity_providers
    idp_alias = "integration-idp-#{SecureRandom.hex(4)}"

    idp_representation = KeycloakAdmin::IdentityProviderRepresentation.new(
      idp_alias, idp_alias, nil, "github", true, nil, nil, nil, nil, nil, nil, nil, nil,
      {"clientId" => "fake-client", "clientSecret" => "fake-secret"}
    )

    idp_client.create(idp_representation)

    # 2. Fetch the IDP
    fetched_idp = idp_client.get(idp_alias)
    expect(fetched_idp.alias).to eq(idp_alias)
    expect(fetched_idp.provider_id).to eq("github")

    # 3. List IDPs
    idp_list = idp_client.list
    expect(idp_list.map(&:alias)).to include(idp_alias)

    # IdentityProviderClient does not have a delete method in this library version
  end

  it 'handles errors when creating a duplicate IDP' do
    idp_client = KeycloakAdmin.realm(realm_name).identity_providers
    idp_alias = "duplicate-idp-#{SecureRandom.hex(4)}"

    idp_representation = KeycloakAdmin::IdentityProviderRepresentation.new(
      idp_alias, idp_alias, nil, "github", true, nil, nil, nil, nil, nil, nil, nil, nil,
      {"clientId" => "fake-client", "clientSecret" => "fake-secret"}
    )

    idp_client.create(idp_representation)

    expect {
      idp_client.create(idp_representation)
    }.to raise_error(KeycloakAdmin::ApiError)
  end

  it 'handles errors when getting a non-existent IDP' do
    idp_client = KeycloakAdmin.realm(realm_name).identity_providers
    expect {
      idp_client.get("invalid-idp-1234")
    }.to raise_error(KeycloakAdmin::ApiError)
  end
end
