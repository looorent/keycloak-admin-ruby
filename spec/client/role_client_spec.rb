RSpec.describe KeycloakAdmin::RoleClient do
  describe "#roles_url" do
    let(:realm_name) { "valid-realm" }
    let(:role_id)    { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).roles.roles_url(role_id)
    end

    context "when role_id is not defined" do
      let(:role_id) { nil }
      it "return a proper url without role id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/roles"
      end
    end

    context "when role_id is defined" do
      let(:role_id) { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "return a proper url with the role id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/roles/95985b21-d884-4bbd-b852-cb8cd365afc2"
      end
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @role_client = KeycloakAdmin.realm(realm_name).roles

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"test_role_id","name":"test_role_name"}]'
    end

    it "lists roles" do
      roles = @role_client.list
      expect(roles.length).to eq 1
      expect(roles[0].name).to eq "test_role_name"
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/roles", rest_client_options).and_call_original

      roles = @role_client.list
      expect(roles.length).to eq 1
      expect(roles[0].name).to eq "test_role_name"
    end
  end

  describe "#save" do
    let(:realm_name) { "valid-realm" }
    let(:role) { KeycloakAdmin::RoleRepresentation.from_hash(
      "name" => "test_role_name",
      "composite" => false,
      "clientRole" => false
    )}

    before(:each) do
      @role_client = KeycloakAdmin.realm(realm_name).roles

      stub_token_client
      expect_any_instance_of(RestClient::Resource).to receive(:post).with(role.to_json, anything)
    end

    it "saves a role" do
      @role_client.save(role)
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/roles", rest_client_options).and_call_original

      @role_client.save(role)
    end
  end
end
