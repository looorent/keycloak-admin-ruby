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

  describe "#get" do
    let(:realm_name) { "valid-realm" }
    let(:id) { "test_client_id" }
    let(:client_name) { "test_client_name" }

    before(:each) do
      @client_client = KeycloakAdmin.realm(realm_name).clients

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"id":"test_client_id","name":"test_client_name"}'
    end

    it "finds a client" do
      client = @client_client.get(id)
      expect(client.name).to eq client_name
      expect(client.id).to eq id
    end
  end

  describe "#find_by_client_id" do
    let(:realm_name) { "valid-realm" }
    let(:client_id) { "my_client_id" }
    let(:client_name) { "test_client_name" }

    before(:each) do
      @client_client = KeycloakAdmin.realm(realm_name).clients

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"test_client_id","clientId": "my_client_id","name":"test_client_name"},{"id":"test_client_id_2","clientId":"client_id_2","name":"test_client_name_2"}]'
    end

    it "finds a client it has" do
      client = @client_client.find_by_client_id(client_id)
      expect(client.name).to eq client_name
      expect(client.client_id).to eq client_id
    end

    it "returns nil if it doesn't have the client" do
      client = @client_client.find_by_client_id("client_id_3")
      expect(client).to be_nil
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
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/clients", rest_client_options).and_call_original

      clients = @client_client.list
      expect(clients.length).to eq 1
      expect(clients[0].name).to eq "test_client_name"
    end
  end

  describe "#update" do
    let(:realm_name) { "valid-realm" }
    let(:client) { KeycloakAdmin::ClientRepresentation.from_hash({ "id" => "test_client_id", "clientId" => "my-client", "name" => "old_name" }) }

    before(:each) do
      @client_client = KeycloakAdmin.realm(realm_name).clients

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:put).and_return ''
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"id":"test_client_id", "clientId": "my-client","name":"new_name"}'
    end

    it "updates a client" do
      updated_client = @client_client.update(client)

      expect(updated_client.name).to eq "new_name"
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @client_client = KeycloakAdmin.realm(realm_name).clients
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return ''
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options
      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/clients/95b45037-3980-404c-ba12-784fa1baf2c2", rest_client_options).and_call_original
      @client_client.delete("95b45037-3980-404c-ba12-784fa1baf2c2")
    end
  end
end
