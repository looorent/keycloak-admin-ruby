RSpec.describe KeycloakAdmin::ClientAuthzScopeClient do
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
      @client_authz_scope = KeycloakAdmin.realm(realm_name).authz_scopes(client_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"c0779ce3-0900-4ea3-b1d6-b23e1f19c662","name":"GET","iconUri":"http://asdfasd1","displayName":"GET authz scope"},{"id":"d0779ce3-0900-4ea3-b1d6-b23e1f19c662","name":"POST","iconUri":"http://asdfasd2","displayName":"POST authz scope"}]'
    end

    it "returns list of authz scopes" do
      response = @client_authz_scope.list
      expect(response.size).to eq 2
      expect(response.first.id).to eq "c0779ce3-0900-4ea3-b1d6-b23e1f19c662"
      expect(response.first.name).to eq "GET"
      expect(response.first.display_name).to eq "GET authz scope"
      expect(response.first.icon_uri).to eq "http://asdfasd1"
    end
  end
end