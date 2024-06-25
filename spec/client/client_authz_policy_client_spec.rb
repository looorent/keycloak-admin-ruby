RSpec.describe KeycloakAdmin::ClientAuthzPolicyClient do


  describe '#authz_policy_url' do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "valid-client-id" }
    let(:type) { :role }
    before(:each) do
      @client_authz_policy = KeycloakAdmin.realm(realm_name).authz_policies(client_id, type)
    end

    it "return a proper url" do
      expect(@client_authz_policy.authz_policy_url(client_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/valid-client-id/authz/resource-server/policy/role?permission=false"
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

end