RSpec.describe KeycloakAdmin::ClientAuthzScopeProtocolMapperClient do
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
        expect { KeycloakAdmin.realm(realm_name).client_authz_scope_protocol_mappers(client_scope_id) }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      it "raises an argument error" do
        expect { KeycloakAdmin.realm(nil).client_authz_scope_protocol_mappers(client_scope_id) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#list" do
    subject { @client.list }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_authz_scope_protocol_mappers(client_scope_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return stub_response
    end

    context "with a hardcoded claim mapper" do
      let(:stub_response) { "[#{mapper_json}]" }

      its(:size)  { is_expected.to eq 1 }
      its(:first) { is_expected.to have_attributes(id: "valid-mapper-id", name: "my-claim", protocol: "openid-connect", protocolMapper: "oidc-hardcoded-claim-mapper") }
    end

    context "with an audience mapper" do
      let(:stub_response) { "[#{audience_mapper_json}]" }

      its(:size)  { is_expected.to eq 1 }
      its(:first) { is_expected.to have_attributes(name: "audience-config-rvw-123", protocol: "openid-connect", protocolMapper: "oidc-audience-mapper") }
    end

    context "with multiple mappers" do
      let(:stub_response) { "[#{mapper_json},#{audience_mapper_json}]" }

      its(:size) { is_expected.to eq 2 }
      it         { expect(subject.map(&:name)).to include("my-claim", "audience-config-rvw-123") }
    end
  end

  describe "#get" do
    subject { @client.get(mapper_id) }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_authz_scope_protocol_mappers(client_scope_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return stub_response
    end

    context "with a hardcoded claim mapper" do
      let(:stub_response) { mapper_json }

      its(:id)             { is_expected.to eq "valid-mapper-id" }
      its(:name)           { is_expected.to eq "my-claim" }
      its(:protocol)       { is_expected.to eq "openid-connect" }
      its(:protocolMapper) { is_expected.to eq "oidc-hardcoded-claim-mapper" }
    end

    context "with an audience mapper" do
      let(:stub_response) { audience_mapper_json }

      its(:name)           { is_expected.to eq "audience-config-rvw-123" }
      its(:protocol)       { is_expected.to eq "openid-connect" }
      its(:protocolMapper) { is_expected.to eq "oidc-audience-mapper" }
      its(:config)         { is_expected.to include("included.custom.audience" => "https://api.example.com", "access.token.claim" => "true", "introspection.token.claim" => "true", "id.token.claim" => "false") }
    end
  end

  describe "#create!" do
    subject { @client.create!(mapper_representation) }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_authz_scope_protocol_mappers(client_scope_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return stub_response
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

      its(:id)       { is_expected.to eq "valid-mapper-id" }
      its(:name)     { is_expected.to eq "my-claim" }
      its(:protocol) { is_expected.to eq "openid-connect" }
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

      its(:name)           { is_expected.to eq "audience-config-rvw-123" }
      its(:protocol)       { is_expected.to eq "openid-connect" }
      its(:protocolMapper) { is_expected.to eq "oidc-audience-mapper" }
      its(:config)         { is_expected.to include("included.custom.audience" => "https://api.example.com") }
    end
  end

  describe "#update" do
    subject { @client.update(mapper_representation) }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_authz_scope_protocol_mappers(client_scope_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:put).and_return ""
    end

    context "with a hardcoded claim mapper" do
      let(:mapper_representation) { KeycloakAdmin::ProtocolMapperRepresentation.from_hash(JSON.parse(mapper_json)) }

      it "calls put on the mapper url" do
        expect_any_instance_of(RestClient::Resource).to receive(:put).with(anything, anything)
        subject
      end
    end

    context "with an audience mapper" do
      let(:mapper_representation) { KeycloakAdmin::ProtocolMapperRepresentation.from_hash(JSON.parse(audience_mapper_json)) }

      it "calls put on the mapper url" do
        expect_any_instance_of(RestClient::Resource).to receive(:put).with(anything, anything)
        subject
      end
    end
  end

  describe "#delete" do
    subject { @client.delete(mapper_id) }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).client_authz_scope_protocol_mappers(client_scope_id)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return ""
    end

    it { is_expected.to eq true }
  end

  describe "#protocol_mappers_url" do
    let(:client)   { KeycloakAdmin.realm(realm_name).client_authz_scope_protocol_mappers(client_scope_id) }
    let(:base_url) { "http://auth.service.io/auth/admin/realms/valid-realm/client-scopes/valid-scope-id/protocol-mappers/models" }

    context "without a mapper_id" do
      subject { client.protocol_mappers_url }

      it { is_expected.to eq base_url }
    end

    context "with a mapper_id" do
      subject { client.protocol_mappers_url(mapper_id) }

      it { is_expected.to eq "#{base_url}/valid-mapper-id" }
    end
  end
end
