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
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups", rest_client_options).and_call_original

      groups = @group_client.list
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end
  end

  describe "#save" do
    let(:realm_name) { "valid-realm" }
    let(:group) { KeycloakAdmin::GroupRepresentation.from_hash(
      "name" => "test_group_name"
    )}

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      response = double
      allow(response).to receive(:headers).and_return(
        { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b' }
      )
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return response
    end

    it "saves a group" do
      expect{ @group_client.save(group) }.not_to raise_error
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups", rest_client_options).and_call_original

      expect{ @group_client.save(group) }.not_to raise_error
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
      stub_net_http_res(Net::HTTPCreated)

      group_id = @group_client.create!("test_group_name")
      expect(group_id).to eq 'be061c48-6edd-4783-a726-1a57d4bfa22b'
    end

    it "detects unexpected response to create a group" do
      stub_net_http_res(Net::HTTPOK, 200, 'OK')

      expect{ @group_client.create!("test_group_name") }.to raise_error(
        'Create method returned status OK (Code: 200); expected status: Created (201)'
      )
    end

    def stub_net_http_res(res_class, code = 200, message = 'OK')
      net_http_res = double
      allow(net_http_res).to receive(:message).and_return message
      allow(net_http_res).to receive(:code).and_return code
      allow(net_http_res).to receive(:is_a?) do |target_class|
        target_class == res_class
      end
      allow(@response).to receive(:net_http_res).and_return net_http_res
    end
  end
end
