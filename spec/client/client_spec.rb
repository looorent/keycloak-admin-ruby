RSpec.describe KeycloakAdmin::Client do
  describe "#server_url" do
    def client_with_server_url(server_url)
      configuration = KeycloakAdmin::Configuration.new
      configuration.server_url = server_url
      KeycloakAdmin::Client.new(configuration)
    end

    it "returns the configured url untouched when it has no trailing slash" do
      expect(client_with_server_url("http://auth.service.io/auth").server_url).to eql "http://auth.service.io/auth"
    end

    it "strips a trailing slash so built paths stay normalized" do
      expect(client_with_server_url("http://auth.service.io/auth/").server_url).to eql "http://auth.service.io/auth"
    end

    it "strips repeated trailing slashes" do
      expect(client_with_server_url("http://localhost:8080///").server_url).to eql "http://localhost:8080"
    end

    it "returns nil when no url is configured" do
      expect(client_with_server_url(nil).server_url).to be_nil
    end
  end

  describe "#execute_http" do
    let(:realm_name) { "valid-realm" }
    before(:each) do
      @client = KeycloakAdmin::Client.new(KeycloakAdmin.config)
    end

    it "handles timeout" do
      expect do
        @client.execute_http do
          raise RestClient::Exceptions::OpenTimeout.new
        end
      end.to raise_error(RestClient::Exceptions::OpenTimeout)
    end

    it "handles response exception" do
      response = double
      allow(response).to receive(:code).and_return 500
      allow(response).to receive(:body).and_return "Server error"

      expect do
        @client.execute_http do
          raise RestClient::ExceptionWithResponse.new(response)
        end
      end.to raise_error("Keycloak: The request failed with response code 500 and message: Server error")
    end
  end
end
