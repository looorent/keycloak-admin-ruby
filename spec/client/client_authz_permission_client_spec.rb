RSpec.describe KeycloakAdmin::ClientAuthzPermissionClient do
  describe '#authz_permission_url' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    before(:each) do
      @client_authz_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource")
    end

    it "return a proper url" do
      expect(@client_authz_permission.authz_permission_url(client_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/permission/resource"
    end
  end

  describe '#delete' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    before(:each) do
      @client_authz_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource")
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return 'true'
    end

    it "deletes a permission" do
      expect(@client_authz_permission.delete("valid-permission-id")).to eq true
    end
  end

  describe '#authz_permission_url' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    before(:each) do
      @client_authz_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource")
    end

    it "return a proper url" do
      expect(@client_authz_permission.authz_permission_url(client_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/permission/resource"
    end
  end

  describe '#list' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    before(:each) do
      @client_authz_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource")
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"245ce612-ccdc-4426-8ea7-e0e29a718033","name":"Default Permission","description":"A permission that applies to the default resource type","type":"resource","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","resourceType":"urn:dummy-client:resources:default"},{"id":"06a21e38-4e92-466d-8647-ffcd9c7b51c3","name":"delme policy","description":"delme polidy ","type":"resource","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","resourceType":"asdfasdf"}]'

    end

    it "returns list of authz permissions" do
      response = @client_authz_permission.list
      expect(response.size).to eq 2
      expect(response[0].id).to eq "245ce612-ccdc-4426-8ea7-e0e29a718033"
      expect(response[0].name).to eq "Default Permission"
      expect(response[0].description).to eq "A permission that applies to the default resource type"
      expect(response[0].logic).to eq "POSITIVE"
      expect(response[0].decision_strategy).to eq "UNANIMOUS"
      expect(response[0].resource_type).to eq "urn:dummy-client:resources:default"
    end
  end

end
