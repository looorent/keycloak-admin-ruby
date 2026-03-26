RSpec.describe KeycloakAdmin::ClientScopeClient do
  let(:realm_name)      { "valid-realm" }
  let(:client_scope_id) { "valid-scope-id" }

  let(:scope_json) do
    <<~JSON
      {"id":"valid-scope-id","name":"my-scope","description":"A test scope","protocol":"openid-connect","attributes":{"display.on.consent.screen":"true","include.in.token.scope":"true"}}
    JSON
  end

  let(:scope_with_mappers_json) do
    <<~JSON
      {"id":"valid-scope-id","name":"my-scope","description":"A test scope","protocol":"openid-connect","attributes":{},"protocolMappers":[{"id":"mapper-id","name":"my-claim","protocol":"openid-connect","protocolMapper":"oidc-hardcoded-claim-mapper","config":{"claim.name":"my_claim","claim.value":"bar","access.token.claim":"true"}}]}
    JSON
  end

  describe "#initialize" do
    context "when realm_name is defined" do
      it "does not raise any error" do
        expect { KeycloakAdmin.realm(realm_name).client_scopes }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      it "raises an argument error" do
        expect { KeycloakAdmin.realm(nil).client_scopes }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#list" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scopes
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return stub_response
    end

    context "with one scope" do
      let(:stub_response) { "[#{scope_json}]" }

      it "returns one scope" do
        expect(@client.list.size).to eq 1
      end

      it "returns the correct scope attributes" do
        expect(@client.list.first).to have_attributes(
          id:          "valid-scope-id",
          name:        "my-scope",
          description: "A test scope",
          protocol:    "openid-connect"
        )
      end

      it "returns attributes map" do
        expect(@client.list.first.attributes).to include(
          "display.on.consent.screen" => "true",
          "include.in.token.scope"    => "true"
        )
      end
    end

    context "with multiple scopes" do
      let(:second_scope_json) { '{"id":"other-scope-id","name":"other-scope","protocol":"openid-connect"}' }
      let(:stub_response) { "[#{scope_json},#{second_scope_json}]" }

      it "returns two scopes" do
        expect(@client.list.size).to eq 2
      end

      it "includes both scope names" do
        expect(@client.list.map(&:name)).to include("my-scope", "other-scope")
      end
    end
  end

  describe "#get" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scopes
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return stub_response
    end

    context "without protocol mappers" do
      let(:stub_response) { scope_json }

      it "returns the correct id" do
        expect(@client.get(client_scope_id).id).to eq "valid-scope-id"
      end

      it "returns the correct name" do
        expect(@client.get(client_scope_id).name).to eq "my-scope"
      end

      it "returns the correct description" do
        expect(@client.get(client_scope_id).description).to eq "A test scope"
      end

      it "returns the correct protocol" do
        expect(@client.get(client_scope_id).protocol).to eq "openid-connect"
      end

      it "returns an empty protocolMappers list" do
        expect(@client.get(client_scope_id).protocol_mappers).to eq []
      end
    end

    context "with protocol mappers" do
      let(:stub_response) { scope_with_mappers_json }

      it "returns protocol mappers" do
        expect(@client.get(client_scope_id).protocol_mappers.size).to eq 1
      end

      it "returns the correct mapper name" do
        expect(@client.get(client_scope_id).protocol_mappers.first.name).to eq "my-claim"
      end
    end
  end

  describe "#create!" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scopes
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return ""
    end

    let(:scope_representation) do
      scope             = KeycloakAdmin::ClientScopeRepresentation.new
      scope.name        = "my-scope"
      scope.description = "A test scope"
      scope.protocol    = "openid-connect"
      scope.attributes  = { "display.on.consent.screen" => "true", "include.in.token.scope" => "true" }
      scope
    end

    it "creates successfully" do
      expect(@client.create!(scope_representation)).to be true
    end
  end

  describe "#save" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scopes
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:put).and_return ""
    end

    let(:scope_representation) { KeycloakAdmin::ClientScopeRepresentation.from_hash(JSON.parse(scope_json)) }

    it "calls put on the scope url" do
      expect_any_instance_of(RestClient::Resource).to receive(:put).with(anything, anything)
      @client.save(scope_representation)
    end

    it "returns true" do
      expect(@client.save(scope_representation)).to be true
    end
  end

  describe "#search" do
    let(:second_scope_json) { '{"id":"other-scope-id","name":"other-scope","protocol":"openid-connect"}' }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scopes
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return "[#{scope_json},#{second_scope_json}]"
    end

    context "when the name matches one scope" do
      it "returns only the matching scope" do
        expect(@client.search("my-scope").size).to eq 1
      end

      it "returns the correct scope" do
        expect(@client.search("my-scope").first).to have_attributes(id: "valid-scope-id", name: "my-scope")
      end
    end

    context "when the name is a partial match" do
      it "returns all scopes containing the substring" do
        expect(@client.search("scope").size).to eq 2
      end
    end

    context "when no scope matches" do
      it "returns an empty array" do
        expect(@client.search("unknown")).to eq []
      end
    end
  end

  describe "#delete" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scopes
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return ""
    end

    it "returns true" do
      expect(@client.delete(client_scope_id)).to eq true
    end
  end

  describe "#client_scopes_url" do
    let(:client)   { KeycloakAdmin.realm(realm_name).client_scopes }
    let(:base_url) { "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes" }

    context "without a client_scope_id" do
      it "returns the base url" do
        expect(client.client_scopes_url).to eq base_url
      end
    end

    context "with a client_scope_id" do
      it "returns the url with client_scope_id appended" do
        expect(client.client_scopes_url(client_scope_id)).to eq "#{base_url}/valid-scope-id"
      end
    end
  end
end
