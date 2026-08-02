RSpec.describe KeycloakAdmin::ClientScopeProtocolMapperClient do
  let(:realm_name)      { "valid-realm" }
  let(:client_scope_id) { "valid-scope-id" }
  let(:mapper_id)       { "valid-mapper-id" }

  let(:mapper_json) do
    <<~JSON
      {"id":"valid-mapper-id","name":"my-claim","protocol":"openid-connect","protocolMapper":"oidc-hardcoded-claim-mapper","config":{"claim.name":"my_claim","claim.value":"bar","access.token.claim":"true"}}
    JSON
  end

  let(:audience_mapper_json) do
    <<~JSON
      {"protocol":"openid-connect","protocolMapper":"oidc-audience-mapper","name":"audience-config-rvw-123","config":{"included.client.audience":"","included.custom.audience":"https://api.example.com","id.token.claim":"false","access.token.claim":"true","lightweight.claim":"false","introspection.token.claim":"true"}}
    JSON
  end

  describe "#initialize" do
    context "when realm_name is defined" do
      it "does not raise any error" do
        expect { KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(client_scope_id) }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      it "raises an argument error" do
        expect { KeycloakAdmin.realm(nil).client_scope_protocol_mappers(client_scope_id) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#list" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(client_scope_id)
      stub_token_client
      stub_request(:get, "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models").to_return(body: stub_response)
    end

    context "with a hardcoded claim mapper" do
      let(:stub_response) { "[#{mapper_json}]" }

      it "returns one mapper" do
        expect(@client.list.size).to eq 1
      end

      it "returns the correct mapper attributes" do
        expect(@client.list.first).to have_attributes(id: "valid-mapper-id", name: "my-claim", protocol: "openid-connect", protocolMapper: "oidc-hardcoded-claim-mapper")
      end
    end

    context "with an audience mapper" do
      let(:stub_response) { "[#{audience_mapper_json}]" }

      it "returns one mapper" do
        expect(@client.list.size).to eq 1
      end

      it "returns the correct mapper attributes" do
        expect(@client.list.first).to have_attributes(name: "audience-config-rvw-123", protocol: "openid-connect", protocolMapper: "oidc-audience-mapper")
      end
    end

    context "with multiple mappers" do
      let(:stub_response) { "[#{mapper_json},#{audience_mapper_json}]" }

      it "returns two mappers" do
        expect(@client.list.size).to eq 2
      end

      it "includes both mapper names" do
        expect(@client.list.map(&:name)).to include("my-claim", "audience-config-rvw-123")
      end
    end
  end

  describe "#get" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(client_scope_id)
      stub_token_client
      stub_request(:get, "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models/valid-mapper-id").to_return(body: stub_response)
    end

    context "with a hardcoded claim mapper" do
      let(:stub_response) { mapper_json }

      it "returns the correct id" do
        expect(@client.get(mapper_id).id).to eq "valid-mapper-id"
      end

      it "returns the correct name" do
        expect(@client.get(mapper_id).name).to eq "my-claim"
      end

      it "returns the correct protocol" do
        expect(@client.get(mapper_id).protocol).to eq "openid-connect"
      end

      it "returns the correct protocolMapper" do
        expect(@client.get(mapper_id).protocolMapper).to eq "oidc-hardcoded-claim-mapper"
      end
    end

    context "with an audience mapper" do
      let(:stub_response) { audience_mapper_json }

      it "returns the correct name" do
        expect(@client.get(mapper_id).name).to eq "audience-config-rvw-123"
      end

      it "returns the correct protocol" do
        expect(@client.get(mapper_id).protocol).to eq "openid-connect"
      end

      it "returns the correct protocolMapper" do
        expect(@client.get(mapper_id).protocolMapper).to eq "oidc-audience-mapper"
      end

      it "returns the correct config" do
        expect(@client.get(mapper_id).config).to include(
          "included.custom.audience"  => "https://api.example.com",
          "access.token.claim"        => "true",
          "introspection.token.claim" => "true",
          "id.token.claim"            => "false"
        )
      end
    end
  end

  describe "#create!" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(client_scope_id)
      stub_token_client
      stub_request(:post, "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models").to_return(body: stub_response)
    end

    context "with a hardcoded claim mapper" do
      let(:stub_response) { mapper_json }
      let(:mapper_representation) do
        mapper = KeycloakAdmin::ProtocolMapperRepresentation.new
        mapper.name           = "my-claim"
        mapper.protocol       = "openid-connect"
        mapper.protocolMapper = "oidc-hardcoded-claim-mapper"
        mapper.config         = { "claim.name" => "my_claim", "claim.value" => "bar", "access.token.claim" => "true" }
        mapper
      end

      it "creates successfully" do
        expect(@client.create!(mapper_representation)).to be true
      end
    end

    context "with an audience mapper" do
      let(:stub_response)         { audience_mapper_json }
      let(:mapper_representation) do
        mapper = KeycloakAdmin::ProtocolMapperRepresentation.new
        mapper.name           = "audience-config-rvw-123"
        mapper.protocol       = "openid-connect"
        mapper.protocolMapper = "oidc-audience-mapper"
        mapper.config         = {
          "included.client.audience"  => "",
          "included.custom.audience"  => "https://api.example.com",
          "id.token.claim"            => "false",
          "access.token.claim"        => "true",
          "lightweight.claim"         => "false",
          "introspection.token.claim" => "true"
        }
        mapper
      end

      it "creates successfully" do
        expect(@client.create!(mapper_representation)).to be true
      end
    end
  end

  describe "#save" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(client_scope_id)
      stub_token_client
    end

    context "with a hardcoded claim mapper" do
      let(:mapper_representation) { KeycloakAdmin::ProtocolMapperRepresentation.from_hash(JSON.parse(mapper_json)) }

      it "calls put on the mapper url" do
        request = stub_request(:put, "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models/valid-mapper-id").to_return(body: "")
        @client.save(mapper_representation)
        expect(request).to have_been_requested
      end
    end

    context "with an audience mapper" do
      let(:mapper_representation) do
        rep = KeycloakAdmin::ProtocolMapperRepresentation.from_hash(JSON.parse(audience_mapper_json))
        rep.id = "audience-mapper-id"
        rep
      end

      it "calls put on the mapper url" do
        request = stub_request(:put, "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models/audience-mapper-id").to_return(body: "")
        @client.save(mapper_representation)
        expect(request).to have_been_requested
      end
    end
  end

  describe "#delete" do
    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(client_scope_id)
      stub_token_client
      stub_request(:delete, "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models/valid-mapper-id").to_return(body: "")
    end

    it "returns true" do
      expect(@client.delete(mapper_id)).to eq true
    end
  end

  describe "#protocol_mappers_url" do
    let(:client)   { KeycloakAdmin.realm(realm_name).client_scope_protocol_mappers(client_scope_id) }
    let(:base_url) { "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models" }

    context "without a mapper_id" do
      it "returns the base url" do
        expect(client.protocol_mappers_url).to eq base_url
      end
    end

    context "with a mapper_id" do
      it "returns the url with mapper_id appended" do
        expect(client.protocol_mappers_url(mapper_id)).to eq "#{base_url}/valid-mapper-id"
      end
    end
  end
end
