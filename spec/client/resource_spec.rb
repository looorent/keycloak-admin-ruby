# frozen_string_literal: true
RSpec.describe KeycloakAdmin::Resource do
  describe "#connection (the real Faraday connection, not stubbed)" do
    def middleware_classes(resource)
      resource.send(:connection).builder.handlers
    end

    it "does not register the logger middleware when no logger is configured" do
      resource = KeycloakAdmin::Resource.new("http://example.com")
      expect(middleware_classes(resource)).to_not include(Faraday::Response::Logger)
    end

    it "registers the logger middleware when a logger is configured" do
      resource = KeycloakAdmin::Resource.new("http://example.com", {}, Logger.new(IO::NULL))
      expect(middleware_classes(resource)).to include(Faraday::Response::Logger)
    end

    it "orders :raise_error before :logger, so a response is logged even when it raises" do
      resource = KeycloakAdmin::Resource.new("http://example.com", {}, Logger.new(IO::NULL))
      handlers = middleware_classes(resource)
      expect(handlers.index(Faraday::Response::RaiseError)).to be < handlers.index(Faraday::Response::Logger)
    end

    it "logs method/url/status but never headers, since Faraday logs headers by default and one of them is the bearer token" do
      log_output = StringIO.new
      logger     = Logger.new(log_output)
      
      stub_request(:get, "http://example.com/x").to_return(status: 200, body: "ok")

      resource = KeycloakAdmin::Resource.new("http://example.com/x", {}, logger)
      
      resource.get(Authorization: "Bearer super-secret-token")

      expect(log_output.string).to include("request: GET")
      expect(log_output.string).to include("response: Status 200")
      expect(log_output.string).to_not include("super-secret-token")
      expect(log_output.string).to_not include("Authorization")
    end
  end

  describe "#connection adapter" do
    def adapter_class(resource)
      resource.send(:connection).builder.adapter.klass
    end

    it "mounts Faraday's default adapter when none is configured" do
      resource = KeycloakAdmin::Resource.new("http://example.com")
      expect(adapter_class(resource)).to eq Faraday::Adapter::NetHttp
    end

    it "mounts the configured adapter instead" do
      resource = KeycloakAdmin::Resource.new("http://example.com", adapter: :test)
      expect(adapter_class(resource)).to eq Faraday::Adapter::Test
    end

    it "accepts an adapter given with its arguments" do
      resource = KeycloakAdmin::Resource.new("http://example.com", adapter: [:test, Faraday::Adapter::Test::Stubs.new])
      expect(adapter_class(resource)).to eq Faraday::Adapter::Test
    end

    it "does not forward :adapter to Faraday as a connection option" do
      expect(Faraday).to receive(:new).with(hash_excluding(:adapter)).and_call_original
      KeycloakAdmin::Resource.new("http://example.com", adapter: :test).send(:connection)
    end

    it "does not mutate the options hash it was given" do
      options = { adapter: :test, request: { timeout: 5 } }
      KeycloakAdmin::Resource.new("http://example.com", options)
      expect(options).to eq({ adapter: :test, request: { timeout: 5 } })
    end
  end

  describe "#get" do
    it "humanizes symbol header keys into HTTP header names" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:get, "http://example.com/users").with(
        headers: {
          "Authorization" => "Bearer token",
          "Content-Type"  => "application/json",
          "Accept"        => "application/json"
        }
      ).to_return(status: 200, body: "ok")

      resource.get(Authorization: "Bearer token", content_type: :json, accept: :json)

      expect(req).to have_been_requested
    end

    it "extracts :params into the query string instead of sending it as a header" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:get, "http://example.com/users?search=jean").with(
        headers: { "Authorization" => "Bearer token" }
      ).to_return(status: 200, body: "ok")

      resource.get(Authorization: "Bearer token", params: { search: "jean" })

      expect(req).to have_been_requested
    end

    it "passes a string content_type through unchanged" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:get, "http://example.com/users").with(
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      ).to_return(status: 200, body: "ok")

      resource.get(content_type: "application/x-www-form-urlencoded")

      expect(req).to have_been_requested
    end

    it "does not set a body" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:get, "http://example.com/users").with { |request| request.body.nil? || request.body.empty? }.to_return(status: 200, body: "ok")

      resource.get({})

      expect(req).to have_been_requested
    end

    it "wraps the Faraday response in a KeycloakAdmin::Response" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      stub_request(:get, "http://example.com/users").to_return(status: 200, body: "ok")

      expect(resource.get({})).to be_a KeycloakAdmin::Response
    end
  end

  describe "#post" do
    it "sends a pre-serialized string payload as the body unchanged" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:post, "http://example.com/users").with(
        body: '{"username":"jean"}',
        headers: { "Content-Type" => "application/json" }
      ).to_return(status: 200, body: "ok")

      resource.post('{"username":"jean"}', content_type: :json)

      expect(req).to have_been_requested
    end

    it "form-encodes a Hash payload" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:post, "http://example.com/users").with(
        body: "email=a%40b.com&firstName=Jean+Yves"
      ).to_return(status: 200, body: "ok")

      resource.post({ email: "a@b.com", firstName: "Jean Yves" }, {})

      expect(req).to have_been_requested
    end

    it "stamps Content-Type: application/x-www-form-urlencoded for a Hash payload when none was set" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:post, "http://example.com/users").with(
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      ).to_return(status: 200, body: "ok")

      resource.post({ id: "42" }, {})

      expect(req).to have_been_requested
    end

    it "does not override an explicit Content-Type for a Hash payload" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      
      req = stub_request(:post, "http://example.com/users").with(
        headers: { "Content-Type" => "application/vnd.custom+form" }
      ).to_return(status: 200, body: "ok")

      resource.post({ id: "42" }, content_type: "application/vnd.custom+form")

      expect(req).to have_been_requested
    end
  end

  describe "#delete" do
    it "sends no body and only the given headers" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users/1")
      
      req = stub_request(:delete, "http://example.com/users/1").with(
        headers: { "Authorization" => "Bearer token" }
      ).with { |request| request.body.nil? || request.body.empty? }.to_return(status: 200, body: "ok")

      resource.delete(Authorization: "Bearer token")

      expect(req).to have_been_requested
    end
  end

  describe ".execute (RestClient::Request.execute equivalent)" do
    it "dispatches an arbitrary method with a payload, including DELETE with a body" do
      req = stub_request(:delete, "http://example.com/mappings").with(
        body: '[{"id":"1"}]',
        headers: { "Content-Type" => "application/json" }
      ).to_return(status: 200, body: "ok")

      KeycloakAdmin::Resource.execute(
        method: :delete,
        url: "http://example.com/mappings",
        payload: '[{"id":"1"}]',
        headers: { content_type: :json }
      )

      expect(req).to have_been_requested
    end

    it "forwards non-method/url/payload/headers keys as connection options" do
      stub_request(:get, "http://example.com/x").to_return(status: 200, body: "ok")
      
      expected_options = { request: { timeout: 5 } }
      expect(KeycloakAdmin::Resource).to receive(:new).with("http://example.com/x", expected_options, nil).and_call_original

      KeycloakAdmin::Resource.execute(method: :get, url: "http://example.com/x", headers: {}, request: { timeout: 5 })
    end

    it "extracts :logger and passes it positionally instead of leaving it in connection options" do
      stub_request(:get, "http://example.com/x").to_return(status: 200, body: "ok")
      
      logger = Logger.new(IO::NULL)
      expect(KeycloakAdmin::Resource).to receive(:new).with("http://example.com/x", {}, logger).and_call_original

      KeycloakAdmin::Resource.execute(method: :get, url: "http://example.com/x", headers: {}, logger: logger)
    end
  end
end
