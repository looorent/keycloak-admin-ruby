RSpec.describe KeycloakAdmin::RoleMapperClient do
  describe "#available_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { "test_user" }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).user(user_id).role_mapper.realm_level_url
    end

    it "return a proper url" do
      expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user/role-mappings/realm"
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { "test_user" }

    before(:each) do
      @role_mapper_client = KeycloakAdmin.realm(realm_name).user(user_id).role_mapper

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get)
        .and_return '[{"id":"test_role_id","name":"test_role_name","composite": false}]'
    end

    it "list user realm-level role mappings" do
      roles = @role_mapper_client.list
      expect(roles.length).to eq 1
      expect(roles[0].id).to eq "test_role_id"
      expect(roles[0].name).to eq "test_role_name"
      expect(roles[0].composite).to be false
    end
  end

  describe "#save_realm_level" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { "test_user" }
    let(:role_list) { [
      KeycloakAdmin::RoleRepresentation.from_hash(
        "name" => "test_role_name",
        "composite" => false,
        "clientRole" => false
      )
    ] }

    before(:each) do
      @role_mapper_client = KeycloakAdmin.realm(realm_name).user(user_id).role_mapper

      stub_token_client
      expect_any_instance_of(RestClient::Resource).to receive(:post).with(role_list.to_json, anything)
    end

    it "saves realm-elevel role mappings" do
      @role_mapper_client.save_realm_level(role_list)
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user/role-mappings/realm", rest_client_options).and_call_original

      @role_mapper_client.save_realm_level(role_list)
    end
  end

  describe "#remove_realm_level" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { "test_user" }
    let(:role_list) { [
      KeycloakAdmin::RoleRepresentation.from_hash(
        "id" => "d9e3376b-f602-4086-8eee-89fea73c73ea"
      )
    ] }
    let(:expected_url) { "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user/role-mappings/realm" }

    before(:each) do
      @role_mapper_client = KeycloakAdmin.realm(realm_name).user(user_id).role_mapper

      stub_token_client
    end

    it "removes realm-level role mappings" do
      expect(RestClient::Request).to receive(:execute).with(
        hash_including(
          method: :delete,
          url: expected_url,
          payload: role_list.to_json
        )
      )

      @role_mapper_client.remove_realm_level(role_list)
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options
      
      expect(RestClient::Request).to receive(:execute).with(
        hash_including(
          method: :delete,
          url: expected_url,
          payload: role_list.to_json,
          timeout: 10
        )
      )

      @role_mapper_client.remove_realm_level(role_list)
    end
  end
end
