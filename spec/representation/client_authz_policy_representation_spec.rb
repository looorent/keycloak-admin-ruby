# frozen_string_literal: true

RSpec.describe KeycloakAdmin::ClientAuthzPolicyRepresentation do
  let(:realm_name) { "valid-realm" }
  let(:client_id) { "valid-client-id" }
  let(:policy_id) { "valid-policy-id" }
  let(:role_id) { "valid-role-id" }
  let(:role_name) { "valid-role-name" }
  let(:policy_name) { "valid-policy-name" }
  let(:policy_description) { "valid-policy-description" }
  let(:policy_type) { "role" }
  let(:policy_logic) { "POSITIVE" }
  let(:policy_decision_strategy) { "UNANIMOUS" }
  let(:policy) do
    {
      "id": policy_id,
      "name": policy_name,
      "description": policy_description,
      "type": policy_type,
      "logic": policy_logic,
      "decisionStrategy": policy_decision_strategy,
      "roles": [{ "id": role_id, "required": true }]
    }
  end
  let(:client_authz_policy) { KeycloakAdmin.realm(realm_name).authz_policies(client_id, 'role') }

  before(:each) do
    stub_token_client
  end

  describe "#create!" do
    before(:each) do
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return policy.to_json
    end

    it "returns created authz policy" do
      response = client_authz_policy.create!(policy_name, policy_description, policy_type, policy_logic, policy_decision_strategy, true, [{ id: role_id, required: true }])
      expect(response.id).to eq policy_id
      expect(response.name).to eq policy_name
      expect(response.description).to eq policy_description
      expect(response.type).to eq policy_type
      expect(response.logic).to eq policy_logic
      expect(response.decision_strategy).to eq policy_decision_strategy
      expect(response.roles).to eq [{ "id" => role_id, "required" => true }]
    end
  end
end