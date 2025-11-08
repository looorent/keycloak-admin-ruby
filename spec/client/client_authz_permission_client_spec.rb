RSpec.describe KeycloakAdmin::ClientAuthzPermissionClient do

  describe "#initialize" do
    let(:realm_name) { nil }
    let(:type) { :scope }
    before(:each) do
      @realm = KeycloakAdmin.realm(realm_name)
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master" }
      it "does not raise any error" do
        expect {
          @realm.authz_permissions("", type)
        }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "raises any error" do
        expect {
          @realm.authz_permissions("", type)
        }.to raise_error(ArgumentError)
      end
    end

    context "when type is bad value" do
      let(:realm_name) { "master" }
      let(:type) { "bad-type" }
      it "does not raise any error" do
        expect {
          @realm.authz_permissions("", type)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#delete' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:client_authz_permission) {  KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource") }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return 'true'
    end

    it "deletes a permission" do
      expect(client_authz_permission.delete("valid-permission-id")).to be_truthy
    end
  end

  describe '#find_by' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:client_authz_permission) {  KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource") }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"245ce612-ccdc-4426-8ea7-e0e29a718033","name":"Default Permission","description":"A permission that applies to the default resource type","type":"resource","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","resourceType":"urn:dummy-client:resources:default"},{"id":"06a21e38-4e92-466d-8647-ffcd9c7b51c3","name":"delme policy","description":"delme polidy ","type":"resource","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","resourceType":"asdfasdf"}]'
    end

    it "finds permissions" do
      response = client_authz_permission.find_by("name", "resource", "scope")
      expect(response[0].id).to eql "245ce612-ccdc-4426-8ea7-e0e29a718033"
      expect(response[1].id).to eql "06a21e38-4e92-466d-8647-ffcd9c7b51c3"
    end
  end

  describe '#create!' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:client_authz_permission) {  KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource") }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return '{"id":"245ce612-ccdc-4426-8ea7-e0e29a718033","name":"Default Permission","description":"A permission that applies to the default resource type","type":"resource","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","resourceType":"urn:dummy-client:resources:default"}'
    end

    it "creates a permission" do
      response = client_authz_permission.create!("name", "description", "UNANIMOUS", "POSITIVE", [], [], [], "resource")
      expect(response.id).to eql "245ce612-ccdc-4426-8ea7-e0e29a718033"
      expect(response.name).to eql "Default Permission"
      expect(response.description).to eql "A permission that applies to the default resource type"
      expect(response.logic).to eql "POSITIVE"
      expect(response.decision_strategy).to eql "UNANIMOUS"
      expect(response.resource_type).to eql "urn:dummy-client:resources:default"
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

  describe '#get' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:client_authz_permission) {  KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource") }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"id":"245ce612-ccdc-4426-8ea7-e0e29a718033","name":"Default Permission","description":"A permission that applies to the default resource type","type":"resource","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","resourceType":"urn:dummy-client:resources:default"}'
    end

    it "gets a permission" do
      response = client_authz_permission.get("245ce612-ccdc-4426-8ea7-e0e29a718033")
      expect(response.id).to eql "245ce612-ccdc-4426-8ea7-e0e29a718033"
      expect(response.name).to eql "Default Permission"
      expect(response.description).to eql "A permission that applies to the default resource type"
      expect(response.logic).to eql "POSITIVE"
      expect(response.decision_strategy).to eql "UNANIMOUS"
      expect(response.resource_type).to eql "urn:dummy-client:resources:default"
    end
  end

  describe '#authz_permission_url' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:resource_id){ "valid-resource-id" }
    let(:type){ "resource" }
    let(:client_authz_permission) { KeycloakAdmin.realm(realm_name).authz_permissions(client_id, type, resource_id) }
    context 'when resource_id is nil' do
      it "return a proper url" do
        expect(client_authz_permission.authz_permission_url(client_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/permission/"
      end
    end
    context 'when resource_id is not nil' do
      it "return a proper url" do
        expect(client_authz_permission.authz_permission_url(client_id, resource_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/resource/valid-resource-id/permissions"
      end
    end
    context 'when id is not nil' do
      it "return a proper url" do
        expect(client_authz_permission.authz_permission_url(client_id, nil, :resource, "valid-permission-id")).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/permission/resource/valid-permission-id"
      end
    end
    context 'when resource_id and id are nil' do
      it "return a proper url" do
        expect(client_authz_permission.authz_permission_url(client_id, nil, :resource)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/permission/resource"
      end
    end
  end

  describe '#authz_permission_url' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    before(:each) do
      @client_authz_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client_id, "resource")
    end

    it "return a proper url" do
      expect(@client_authz_permission.authz_permission_url(client_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/permission/"
    end
  end
end
