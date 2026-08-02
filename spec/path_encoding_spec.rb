RSpec.describe "URL path encoding" do
  let(:realm_name) { "valid-realm" }
  let(:admin_url)  { "http://auth.service.io/auth/admin/realms/valid-realm" }
  let(:unsafe)     { "a b/c" }
  let(:encoded)    { "a%20b%2Fc" }

  describe "identifiers chosen by the user" do
    # The clearest reachable case: an identity provider alias is free text, unlike the UUIDs
    # Keycloak hands out for users, groups and clients.
    it "encodes an identity provider alias" do
      expect(KeycloakAdmin.realm(realm_name).identity_providers.identity_providers_url(unsafe))
        .to eq "#{admin_url}/identity-provider/instances/#{encoded}"
    end

    it "encodes a role name" do
      expect(KeycloakAdmin.realm(realm_name).roles.role_name_url(unsafe))
        .to eq "#{admin_url}/roles/#{encoded}"
    end

    it "encodes a realm name" do
      expect(KeycloakAdmin.realm(unsafe).realm_admin_url)
        .to eq "http://auth.service.io/auth/admin/realms/#{encoded}"
    end
  end

  describe "identifiers Keycloak hands out" do
    it "leaves a UUID untouched" do
      uuid = "95985b21-d884-4bbd-b852-cb8cd365afc2"

      expect(KeycloakAdmin.realm(realm_name).users.users_url(uuid)).to eq "#{admin_url}/users/#{uuid}"
    end

    it "encodes every client that builds an url out of an identifier" do
      realm = KeycloakAdmin.realm(realm_name)

      {
        "users"          => realm.users.users_url(unsafe),
        "groups"         => realm.groups.groups_url(unsafe),
        "clients"        => realm.clients.clients_url(unsafe),
        "client-scopes"  => realm.client_scopes.client_scopes_url(unsafe),
        "roles-by-id"    => realm.roles.role_id_url(unsafe),
        "organizations"  => realm.organizations.organization_url(unsafe),
        "brute-force"    => realm.attack_detections.brute_force_url(unsafe)
      }.each do |label, url|
        expect(url).to end_with(encoded), "#{label} did not encode its identifier: #{url}"
      end
    end

    it "encodes the resource id of a user or group resource" do
      expect(KeycloakAdmin.realm(realm_name).user(unsafe).resource_url).to eq "#{admin_url}/users/#{encoded}"
      expect(KeycloakAdmin.realm(realm_name).group(unsafe).resource_url).to eq "#{admin_url}/groups/#{encoded}"
    end
  end

  describe "the request that comes out of it" do
    before(:each) { stub_token_client }

    it "is actually sent, instead of raising URI::InvalidURIError" do
      request = stub_request(:get, "#{admin_url}/identity-provider/instances/#{encoded}")
        .to_return(status: 200, body: "{}")

      KeycloakAdmin.realm(realm_name).identity_providers.get(unsafe)

      expect(request).to have_been_requested
    end

    it "does not encode an already-safe identifier twice" do
      request = stub_request(:get, "#{admin_url}/roles/my%20role").to_return(status: 200, body: "{}")

      KeycloakAdmin.realm(realm_name).roles.get("my role")

      expect(request).to have_been_requested
    end
  end
end
