# frozen_string_literal: true
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

    it "does not deadlock when the token request itself is rejected" do
      configuration = KeycloakAdmin.config
      configuration.clear_cached_token!
      stub_request(:post, "http://auth.service.io/auth/realms/master2/protocol/openid-connect/token")
        .to_return(status: 401, body: "invalid_client")

      expect { KeycloakAdmin::Client.new(configuration).current_token }
        .to raise_error(KeycloakAdmin::UnauthorizedError)
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

    it "raises the typed error matching the status, carrying status and body" do
      expect do
        @client.execute_http do
          raise Faraday::ClientError.new("boom", status: 404, body: "User not found")
        end
      end.to raise_error(KeycloakAdmin::NotFoundError) { |error|
        expect(error.status).to eq 404
        expect(error.body).to eq "User not found"
      }
    end

    it "raises ApiError when the failure carried no response at all" do
      expect do
        @client.execute_http { raise Faraday::ClientError.new("boom") }
      end.to raise_error(KeycloakAdmin::ApiError)
    end
  end

  describe "#execute_http on 401" do
    def stub_token_fetches(counter)
      allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get) do
        counter[:count] += 1
        KeycloakAdmin::TokenRepresentation.new(
          "token-#{counter[:count]}", "bearer", 3600, nil, nil, nil, nil, nil
        )
      end
    end

    def unauthorized
      Faraday::ClientError.new("expired", status: 401, body: "invalid_token")
    end

    before(:each) do
      @configuration = KeycloakAdmin.config
      @configuration.clear_cached_token!
      @counter = {count: 0}
      stub_token_fetches(@counter)
      @client = KeycloakAdmin::Client.new(@configuration)
    end

    it "drops the cached token and replays the request with a freshly fetched one" do
      tokens_sent = []

      result = @client.execute_http do
        tokens_sent << @client.headers[:Authorization]
        raise unauthorized if tokens_sent.size == 1
        "ok"
      end

      expect(result).to eq "ok"
      expect(tokens_sent).to eq ["Bearer token-1", "Bearer token-2"]
      expect(@counter[:count]).to eq 2
    end

    it "gives up after a single replay when the fresh token is rejected too" do
      attempts = 0

      expect do
        @client.execute_http do
          attempts += 1
          @client.headers
          raise unauthorized
        end
      end.to raise_error(KeycloakAdmin::UnauthorizedError)

      expect(attempts).to eq 2
    end

    it "does not replay when no token was cached, since the credentials themselves are refused" do
      attempts = 0

      expect do
        @client.execute_http do
          attempts += 1
          raise unauthorized
        end
      end.to raise_error(KeycloakAdmin::UnauthorizedError)

      expect(attempts).to eq 1
      expect(@counter[:count]).to eq 0
    end

    it "does not replay a non-401 failure" do
      attempts = 0

      expect do
        @client.execute_http do
          attempts += 1
          @client.headers
          raise Faraday::ClientError.new("nope", status: 403, body: "Forbidden")
        end
      end.to raise_error(KeycloakAdmin::ForbiddenError)

      expect(attempts).to eq 1
    end
  end

  describe "#created_id" do
    before(:each) do
      @client = KeycloakAdmin::Client.new(KeycloakAdmin.config)
    end

    def response(status, location)
      instance_double(
        KeycloakAdmin::Response,
        status: status, reason_phrase: "Created", headers: {location: location}
      )
    end

    it "reads the new resource id from the Location header" do
      expect(@client.created_id(response(201, "http://auth.service.io/auth/admin/realms/x/groups/abc"))).to eq "abc"
    end

    it "raises UnexpectedResponseError when the status is not 201" do
      not_created = instance_double(KeycloakAdmin::Response, status: 204, reason_phrase: "No Content")
      expect { @client.created_id(not_created) }.to raise_error(
        KeycloakAdmin::UnexpectedResponseError,
        "Create method returned status No Content (Code: 204); expected status: Created (201)"
      )
    end
  end

  describe "#build_query" do
    def build_query(parameters)
      KeycloakAdmin::Client.new(KeycloakAdmin.config).send(:build_query, parameters)
    end

    it "percent-encodes values so they cannot forge extra parameters" do
      expect(build_query(search: "a b&c=d")).to eq "search=a%20b%26c%3Dd"
    end

    it "encodes names too" do
      expect(build_query("a name" => "v")).to eq "a%20name=v"
    end

    it "renders a nil value as empty, like the interpolation it replaced" do
      expect(build_query(scope: nil)).to eq "scope="
    end

    it "keeps insertion order and joins with &" do
      expect(build_query(first: 0, max: 11)).to eq "first=0&max=11"
    end

    it "returns an empty string for no parameters" do
      expect(build_query({})).to eq ""
    end
  end
end
