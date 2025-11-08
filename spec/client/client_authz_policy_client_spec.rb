RSpec.describe KeycloakAdmin::ClientAuthzPolicyClient do

  describe '#initialize' do
    let(:realm_name) { nil }
    let(:type) { :role }
    before(:each) do
      @realm = KeycloakAdmin.realm(realm_name)
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master" }
      it "does not raise any error" do
        expect {
          @realm.authz_policies("", type)
        }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "raises any error" do
        expect {
          @realm.authz_policies("", type)
        }.to raise_error(ArgumentError)
      end
    end

    context "when type is bad value" do
      let(:realm_name) { "master" }
      let(:type) { "bad-type" }
      it "does not raise any error" do
        expect {
          @realm.authz_policies("", type)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#create!' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:type) { :role }
    let(:name) { "policy name" }
    let(:description) { "policy description" }
    let(:logic) { "POSITIVE" }
    let(:decision_strategy) { "UNANIMOUS" }
    let(:fetch_roles) { true }
    let(:config) { { roles: [{ id: "1d305dbe-6379-4900-8e63-96541006160a", required: false }] } }
    let(:client_authz_policy){ KeycloakAdmin.realm(realm_name).authz_policies(client_id, type) }

    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return '{"id":"234f6f33-ef03-4f3f-a8c0-ad7bca27b720","name":"policy name","description":"policy description","type":"role","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","config":{"roles":"[{\"id\":\"1d305dbe-6379-4900-8e63-96541006160a\",\"required\":false}]"}}'
    end

    it "creates a new authz policy" do
      response = client_authz_policy.create!(name, description, type, logic, decision_strategy, fetch_roles, config[:roles])
      expect(response.id).to eq "234f6f33-ef03-4f3f-a8c0-ad7bca27b720"
      expect(response.name).to eq "policy name"
      expect(response.type).to eq "role"
      expect(response.logic).to eq "POSITIVE"
      expect(response.decision_strategy).to eq "UNANIMOUS"
      expect(response.config.roles[0].id).to eq "1d305dbe-6379-4900-8e63-96541006160a"
    end
  end

  describe '#get' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:type) { :role }
    let(:policy_id) { "234f6f33-ef03-4f3f-a8c0-ad7bca27b720" }
    let(:client_authz_policy){ KeycloakAdmin.realm(realm_name).authz_policies(client_id, type) }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"id":"234f6f33-ef03-4f3f-a8c0-ad7bca27b720","name":"policy name","description":"policy description","type":"role","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","config":{"roles":"[{\"id\":\"1d305dbe-6379-4900-8e63-96541006160a\",\"required\":false}]"}}'
    end

    it "returns an authz policy" do
      response = client_authz_policy.get(policy_id)
      expect(response.id).to eq "234f6f33-ef03-4f3f-a8c0-ad7bca27b720"
      expect(response.name).to eq "policy name"
      expect(response.type).to eq "role"
      expect(response.logic).to eq "POSITIVE"
      expect(response.decision_strategy).to eq "UNANIMOUS"
      expect(response.config.roles[0].id).to eq "1d305dbe-6379-4900-8e63-96541006160a"
    end
  end

  describe '#find_by' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:type) { :role }
    let(:name) { "policy name" }
    let(:client_authz_policy){ KeycloakAdmin.realm(realm_name).authz_policies(client_id, type) }
    before(:each) do
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"234f6f33-ef03-4f3f-a8c0-ad7bca27b720","name":"policy name","description":"policy description","type":"role","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","config":{"roles":"[{\"id\":\"1d305dbe-6379-4900-8e63-96541006160a\",\"required\":false}]"}}]'
    end

    it "returns list of authz policies" do
      response = client_authz_policy.find_by(name, type)
      expect(response.size).to eq 1
      expect(response[0].id).to eq "234f6f33-ef03-4f3f-a8c0-ad7bca27b720"
      expect(response[0].name).to eq "policy name"
      expect(response[0].type).to eq "role"
      expect(response[0].logic).to eq "POSITIVE"
      expect(response[0].decision_strategy).to eq "UNANIMOUS"
      expect(response[0].config.roles[0].id).to eq "1d305dbe-6379-4900-8e63-96541006160a"
    end
  end

  describe '#delete' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:type) { :role }
    let(:policy_id) { "234f6f33-ef03-4f3f-a8c0-ad7bca27b720" }
    before(:each) do
      @client_authz_policy = KeycloakAdmin.realm(realm_name).authz_policies(client_id, type)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return 'true'
    end

    it "deletes an authz policy" do
      response = @client_authz_policy.delete(policy_id)
      expect(response).to eq true
    end
  end

  describe '#list' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:type) { :role }
    before(:each) do
      @client_authz_policy = KeycloakAdmin.realm(realm_name).authz_policies(client_id, type)
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"234f6f33-ef03-4f3f-a8c0-ad7bca27b720","name":"policy name","description":"policy description","type":"role","logic":"POSITIVE","decisionStrategy":"UNANIMOUS","config":{"roles":"[{\"id\":\"1d305dbe-6379-4900-8e63-96541006160a\",\"required\":false}]"}}]'
    end

    it "returns list of authz policies" do
      response = @client_authz_policy.list
      expect(response.size).to eq 1
      expect(response[0].id).to eq "234f6f33-ef03-4f3f-a8c0-ad7bca27b720"
      expect(response[0].name).to eq "policy name"
      expect(response[0].type).to eq "role"
      expect(response[0].logic).to eq "POSITIVE"
      expect(response[0].decision_strategy).to eq "UNANIMOUS"
      expect(response[0].config.roles[0].id).to eq "1d305dbe-6379-4900-8e63-96541006160a"
    end
  end

  describe '#authz_policy_url' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:type) { :role }
    let(:client_authz_policy){ KeycloakAdmin.realm(realm_name).authz_policies(client_id, type) }

    context 'when policy_id is nil' do
      let(:policy_id) { nil }
      it "return a proper url" do
        expect(client_authz_policy.authz_policy_url(client_id, type, policy_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/policy/role?permission=false"
      end
    end
    context 'when policy_id is not nil' do
      let(:policy_id) { "234f6f33-ef03-4f3f-a8c0-ad7bca27b720" }
      it "return a proper url" do
        expect(client_authz_policy.authz_policy_url(client_id, type, policy_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/policy/role/234f6f33-ef03-4f3f-a8c0-ad7bca27b720"
      end
    end
  end
end