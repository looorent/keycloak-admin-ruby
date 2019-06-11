RSpec.describe KeycloakAdmin::ClientRoleMappingsClient do
  describe "#available_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { "test_user" }
    let(:client_id)  { "test_client" }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).user(user_id).client_role_mappings(client_id).list_available_url
    end

    it "return a proper url" do
      expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user/role-mappings/clients/test_client/available"
    end
  end

  describe "#list_available" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { "test_user" }
    let(:client_id)  { "test_client" }

    before(:each) do
      @client_role_mappings_client = KeycloakAdmin.realm(realm_name).user(user_id).client_role_mappings(client_id)

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"test_role_id","name":"test_role_name"}]'
    end

    it "lists roles" do
      roles = @client_role_mappings_client.list_available
      expect(roles.length).to eq 1
      expect(roles[0].name).to eq "test_role_name"
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user/role-mappings/clients/test_client/available",
        rest_client_options
      ).and_call_original

      roles = @client_role_mappings_client.list_available
      expect(roles.length).to eq 1
      expect(roles[0].name).to eq "test_role_name"
    end
  end
end
