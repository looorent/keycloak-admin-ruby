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

  describe "#current_token" do
    def token(expires_in)
      KeycloakAdmin::TokenRepresentation.new(
        "access_token", "bearer", expires_in, "refresh_token",
        "refresh_expires_in", "id_token", "not_before_policy", "session_state"
      )
    end

    it "fetches once and reuses the cached token across Client instances sharing the same configuration" do
      configuration = KeycloakAdmin.config
      configuration.clear_cached_token!
      allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get).and_return(token(3600))

      first  = KeycloakAdmin::Client.new(configuration).current_token
      second = KeycloakAdmin::Client.new(configuration).current_token

      expect(first).to be second
      expect(second).to be second
    end

    it "fetches a new token once the cached one has expired" do
      configuration = KeycloakAdmin.config
      configuration.clear_cached_token!
      # allow_any_instance_of's sequential and_return(a, b) tracks call count per instance,
      # and a fresh TokenClient is built on every fetch, so a plain external counter is used
      # instead to force the first fetch to be pre-expired and the second one not to be.
      call_count = 0
      allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get) do
        call_count += 1
        call_count == 1 ? token(5) : token(3600)
      end

      expired_immediately = KeycloakAdmin::Client.new(configuration).current_token
      refreshed            = KeycloakAdmin::Client.new(configuration).current_token

      expect(expired_immediately).to_not be refreshed
      expect(call_count).to eq 2
    end
  end

  describe "#resource" do
    it "builds a Resource with the configuration's faraday_options and logger" do
      configuration = KeycloakAdmin::Configuration.new
      configuration.faraday_options = { timeout: 5 }
      configuration.logger          = Logger.new(IO::NULL)
      client = KeycloakAdmin::Client.new(configuration)

      expect(KeycloakAdmin::Resource).to receive(:new).with("http://x", { timeout: 5 }, configuration.logger)

      client.send(:resource, "http://x")
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
          raise Faraday::TimeoutError.new
        end
      end.to raise_error(Faraday::TimeoutError)
    end

    it "handles response exception" do
      expect do
        @client.execute_http do
          raise Faraday::ServerError.new("boom", status: 500, body: "Server error")
        end
      end.to raise_error("Keycloak: The request failed with response code 500 and message: Server error")
    end
  end
end
