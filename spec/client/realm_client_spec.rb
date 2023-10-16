RSpec.describe KeycloakAdmin::RealmClient do
  describe "#realm_url" do

    let(:realm_name) { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).realm_url
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master2" }
      it "return a proper url with realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/realms/master2"
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "return a proper url without realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/realms"
      end
    end
  end

  describe "#admin_realm_url" do

    let(:realm_name) { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).realm_admin_url
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master2" }
      it "return a proper url with realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/master2"
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "return a proper url without realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms"
      end
    end
  end

  describe "#list" do
    before(:each) do
      @realm_client = KeycloakAdmin.realm('master')

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"id":"test_realm","realm":"test_realm"}]'
    end

    it "lists realms" do
      realms = @realm_client.list
      expect(realms.length).to eq 1
      expect(realms[0].realm).to eq "test_realm"
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms", rest_client_options).and_call_original

      realms = @realm_client.list
      expect(realms.length).to eq 1
      expect(realms[0].realm).to eq "test_realm"
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @realm_client = KeycloakAdmin.realm(realm_name)

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete)
    end

    it "delete realm" do
      expect(@realm_client.delete).to be_truthy
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm", rest_client_options).and_call_original

      expect(@realm_client.delete).to be_truthy
    end
  end

  describe "#save" do
    let(:realm_name) { "valid-realm" }
    let(:realm) { KeycloakAdmin::RealmRepresentation.from_hash(
      "id" => realm_name,
      "realm" => realm_name
    )}

    before(:each) do
      @realm_client = KeycloakAdmin.realm(nil)

      stub_token_client

      expect_any_instance_of(RestClient::Resource).to receive(:post).with(realm.to_json, anything)
    end

    it "saves a realm" do
      @realm_client.save(realm)
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms", rest_client_options).and_call_original

      @realm_client.save(realm)
    end
  end

  describe "#update" do
    let(:realm_name) { "valid-realm" }
    let(:realm_json) { { smtpServer: { host: 'test_host' } } }

    before(:each) do
      @realm_client = KeycloakAdmin.realm(realm_name)

      stub_token_client
      expect_any_instance_of(RestClient::Resource).to receive(:put).with(realm_json.to_json, anything)
    end

    it "updates a realm" do
      @realm_client.update(realm_json)
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm", rest_client_options).and_call_original

      @realm_client.update(realm_json)
    end
  end
end
