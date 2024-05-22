RSpec.describe KeycloakAdmin::GroupClient do
  describe "#groups_url" do
    let(:realm_name) { "valid-realm" }
    let(:group_id)    { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).groups.groups_url(group_id)
    end

    context "when group_id is not defined" do
      let(:group_id) { nil }
      it "return a proper url without group id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/groups"
      end
    end

    context "when group_id is defined" do
      let(:group_id) { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "return a proper url with the group id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/groups/95985b21-d884-4bbd-b852-cb8cd365afc2"
      end
    end
  end

  describe "#get" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"id":"test_group_id","name":"test_group_name"}'
    end

    it "get a group" do
      group = @group_client.get("test_group_id")
      expect(group.id).to eq "test_group_id"
      expect(group.name).to eq "test_group_name"
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id", rest_client_options).and_call_original

      group = @group_client.get("test_group_id")
      expect(group.id).to eq "test_group_id"
      expect(group.name).to eq "test_group_name"
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"test_group_id","name":"test_group_name"}]'
    end

    it "lists groups" do
      groups = @group_client.list
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups", rest_client_options).and_call_original

      groups = @group_client.list
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end
  end


  describe "#children" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"test_group_id","name":"test_group_name"}]'
    end

    it "lists children groups" do
      groups = @group_client.children("parent_group_id")
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups/parent_group_id/children", rest_client_options).and_call_original

      groups = @group_client.children("parent_group_id")
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end
  end

  describe "#save" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
    end

    context "when the group does not exist" do
      let(:group) { KeycloakAdmin::GroupRepresentation.from_hash(
        "name" => "test_group_name"
      )}

      before do
        response = double
        allow(response).to receive(:headers).and_return(
          { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b' }
        )

        expect_any_instance_of(RestClient::Resource).to receive(:post).with(group.to_json, anything).and_return response
      end

      it "saves a group" do
        @group_client.save(group)
      end

      it "passes rest client options" do
        rest_client_options = {timeout: 10}
        allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

        expect(RestClient::Resource).to receive(:new).with(
          "http://auth.service.io/auth/admin/realms/valid-realm/groups", rest_client_options).and_call_original

        @group_client.save(group)
      end
    end

    context "when the group already exists" do
      let(:group) { KeycloakAdmin::GroupRepresentation.from_hash(
        "id" => "test_group_id",
        "name" => "test_group_name"
      )}

      before do
        response = double
        allow(response).to receive(:headers).and_return(
          { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b' }
        )

        expect_any_instance_of(RestClient::Resource).to receive(:put).with(group.to_json, anything).and_return response
      end

      it "saves a group" do
        @group_client.save(group)
      end

      it "passes rest client options" do
        rest_client_options = {timeout: 10}
        allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

        expect(RestClient::Resource).to receive(:new).with(
          "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id", rest_client_options).and_call_original

        @group_client.save(group)
      end
    end
  end

  describe "#create" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      @response = double
      allow(@response).to receive(:headers).and_return(
        { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b' }
      )
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return @response
    end

    it "creates a group" do
      stub_net_http_res(Net::HTTPCreated, 201, 'Created')

      group_id = @group_client.create!("test_group_name")
      expect(group_id).to eq 'be061c48-6edd-4783-a726-1a57d4bfa22b'
    end

    it "detects unexpected response to create a group" do
      stub_net_http_res(Net::HTTPOK, 200, 'OK')

      expect{ @group_client.create!("test_group_name") }.to raise_error(
        'Create method returned status OK (Code: 200); expected status: Created (201)'
      )
    end
  end

  describe "#create_subgroup!" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      @response = double headers: {
        location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/7686af34-204c-4515-8122-78d19febbf6e'
      }
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return @response
    end

    it "creates a subgroup" do
      stub_net_http_res(Net::HTTPCreated, 201, 'Created')

      group_id = @group_client.create_subgroup!('be061c48-6edd-4783-a726-1a57d4bfa22b', 'subgroup-name')
      expect(group_id).to eq '7686af34-204c-4515-8122-78d19febbf6e'
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return ''
    end

    it "deletes a group" do
      result = @group_client.delete("test_group_id")
      expect(result).to be(true)
    end

    it "raises a delete error" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id", rest_client_options).and_raise("error")

      expect { @group_client.delete("test_group_id") }.to raise_error("error")
    end
  end
end
