RSpec.describe KeycloakAdmin::Client do
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
