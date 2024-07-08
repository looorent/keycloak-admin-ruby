RSpec.describe KeycloakAdmin::ClientAuthzResourceClient do
  describe "#initialize" do
    let(:realm_name) { nil }
    before(:each) do
      @realm = KeycloakAdmin.realm(realm_name)
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master" }
      it "does not raise any error" do
        expect { @realm.attack_detections }.to_not raise_error
      end
    end
    context "when realm_name is not defined" do
      it "raise argument error" do
        expect { @realm.attack_detections }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    before(:each) do
      @client_authz_resource = KeycloakAdmin.realm(realm_name).authz_resources(client_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"name":"Default Resource","type":"urn:delme-client-id:resources:default","owner":{"id":"d259b451-371b-432a-a526-3508f3a36f3b","name":"delme-client-id"},"ownerManagedAccess":false,"_id":"94643fe2-1973-4a36-8e1f-830ade186398","uris":["/*"]},{"name":"asdfasdf","type":"urn:delme-client-id:resources:default","owner":{"id":"d259b451-371b-432a-a526-3508f3a36f3b","name":"delme-client-id"},"ownerManagedAccess":true,"displayName":"asdfasdfasdfa","_id":"385966a2-14b9-4cc4-9539-5f2fe1008222","uris":["/*"],"icon_uri":"http://icon"}]'
    end

    it "returns list of authz scopes" do
      response = @client_authz_resource.list
      expect(response.size).to eq 2
      expect(response[1].id).to eq "385966a2-14b9-4cc4-9539-5f2fe1008222"
      expect(response[1].name).to eq "asdfasdf"
      expect(response[1].type).to eq  "urn:delme-client-id:resources:default"
      expect(response[1].owner_managed_access).to be_truthy
    end
  end

  describe '#get' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:resource_id) { "valid-resource-id" }
    let(:client_authz_resource) { KeycloakAdmin.realm(realm_name).authz_resources(client_id) }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"name":"Default Resource","type":"urn:delme-client-id:resources:default","owner":{"id":"d259b451-371b-432a-a526-3508f3a36f3b","name":"delme-client-id"},"ownerManagedAccess":false,"_id":"94643fe2-1973-4a36-8e1f-830ade186398","uris":["/*"]}'
    end

    it "returns authz scope" do
      response = client_authz_resource.get(resource_id)
      expect(response.id).to eq "94643fe2-1973-4a36-8e1f-830ade186398"
      expect(response.name).to eq "Default Resource"
      expect(response.type).to eq  "urn:delme-client-id:resources:default"
      expect(response.owner_managed_access).to be_falsey
    end
  end

  describe '#update' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:resource_id) { "valid-resource-id" }
    let(:client_authz_resource) { KeycloakAdmin.realm(realm_name).authz_resources(client_id) }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"name":"Default Resource","type":"urn:delme-client-id:resources:default","owner":{"id":"d259b451-371b-432a-a526-3508f3a36f3b","name":"delme-client-id"},"ownerManagedAccess":false,"_id":"94643fe2-1973-4a36-8e1f-830ade186398","uris":["/*"]}'
      allow_any_instance_of(RestClient::Resource).to receive(:put).and_return '{"name":"Default Resource","type":"urn:delme-client-id:resources:default","owner":{"id":"d259b451-371b-432a-a526-3508f3a36f3b","name":"delme-client-id"},"ownerManagedAccess":false,"_id":"94643fe2-1973-4a36-8e1f-830ade186398","uris":["/*"]}'
    end

    it "returns updated authz scope" do
      response = client_authz_resource.update(resource_id, {name: "Default Resource", type: "urn:delme-client-id:resources:default", uris: ["/tmp/*"], owner_managed_access: false, display_name: "Default Resource", scopes: []})
      expect(response.id).to eq "94643fe2-1973-4a36-8e1f-830ade186398"
      expect(response.name).to eq "Default Resource"
      expect(response.type).to eq  "urn:delme-client-id:resources:default"
      expect(response.owner_managed_access).to be_falsey
    end
  end

  describe '#create!' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    before(:each) do
      @client_authz_resource = KeycloakAdmin.realm(realm_name).authz_resources(client_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return '{"name":"Default Resource","type":"urn:delme-client-id:resources:default","owner":{"id":"d259b451-371b-432a-a526-3508f3a36f3b","name":"delme-client-id"},"ownerManagedAccess":false,"_id":"94643fe2-1973-4a36-8e1f-830ade186398","uris":["/*"]}'
    end

    it "returns created authz scope" do
      response = @client_authz_resource.create!("Default Resource", "urn:delme-client-id:resources:default", ["/tmp/*"], false, "Default Resource", [])
      expect(response.id).to eq "94643fe2-1973-4a36-8e1f-830ade186398"
      expect(response.name).to eq "Default Resource"
      expect(response.type).to eq  "urn:delme-client-id:resources:default"
      expect(response.owner_managed_access).to be_falsey
    end
  end

  describe "#find_by" do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:resource_id) { "valid-resource-id" }
    let(:client_authz_resource) { KeycloakAdmin.realm(realm_name).authz_resources(client_id) }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"name":"Default Resource","type":"urn:delme-client-id:resources:default","owner":{"id":"d259b451-371b-432a-a526-3508f3a36f3b","name":"delme-client-id"},"ownerManagedAccess":false,"_id":"94643fe2-1973-4a36-8e1f-830ade186398","uris":["/*"]}]'
    end

    it "returns list of authz scopes" do
      response = client_authz_resource.find_by("Default Resource", "urn:delme-client-id:resources:default", ["/tmp/*"], false, "")
      expect(response.size).to eq 1
      expect(response[0].id).to eq "94643fe2-1973-4a36-8e1f-830ade186398"
      expect(response[0].name).to eq "Default Resource"
      expect(response[0].type).to eq  "urn:delme-client-id:resources:default"
      expect(response[0].owner_managed_access).to be_falsey
    end
  end

  describe "#authz_scopes_url" do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:client_authz_resource){ KeycloakAdmin.realm(realm_name).authz_resources(client_id) }

    context 'when resource_id is nil' do
      it "return a proper url" do
        expect(client_authz_resource.authz_resources_url(client_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/resource"
      end
    end

    context 'when resource_id is not nil' do
      it "return a proper url" do
        expect(client_authz_resource.authz_resources_url(client_id, "resource-id")).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/resource/resource-id"
      end
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:resource_id) { "valid-resource-id" }
    let(:client_authz_resource) { KeycloakAdmin.realm(realm_name).authz_resources(client_id) }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return '{}'
    end

    it "returns true" do
      response = client_authz_resource.delete(resource_id)
      expect(response).to be_truthy
    end
  end
end
