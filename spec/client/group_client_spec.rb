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
end
