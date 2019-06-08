RSpec.describe KeycloakAdmin::ClientClient do
  describe "#clients_url" do
    let(:realm_name) { "valid-realm" }
    let(:client_id)    { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).clients.clients_url(client_id)
    end

    context "when client_id is not defined" do
      let(:client_id) { nil }
      it "return a proper url without client id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients"
      end
    end

    context "when client_id is defined" do
      let(:client_id) { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "return a proper url with the client id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/clients/95985b21-d884-4bbd-b852-cb8cd365afc2"
      end
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @client_client = KeycloakAdmin.realm(realm_name).clients

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"test_client_id","name":"test_client_name"}]'
    end

    it "lists clients" do
      clients = @client_client.list
      expect(clients.length).to eq 1
      expect(clients[0].name).to eq "test_client_name"
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/clients", rest_client_options).and_call_original

      clients = @client_client.list
      expect(clients.length).to eq 1
      expect(clients[0].name).to eq "test_client_name"
    end
  end
end
