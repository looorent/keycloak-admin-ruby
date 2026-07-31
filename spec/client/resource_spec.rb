RSpec.describe KeycloakAdmin::Resource do
  # A real, mutable stand-in for the Faraday::Request builder yielded by
  # connection.get/post/put/delete { |req| ... }.
  FakeRequest = Struct.new(:params, :headers) do
    attr_accessor :body
  end

  let(:fake_request)  { FakeRequest.new({}, {}) }
  let(:fake_response) { double(status: 200, body: "ok", headers: {}, reason_phrase: "OK") }

  def stub_connection(resource, verb)
    connection = double
    allow(connection).to receive(verb) do |&block|
      block.call(fake_request) if block
      fake_response
    end
    allow(resource).to receive(:connection).and_return(connection)
    connection
  end

  describe "#get" do
    it "humanizes symbol header keys into HTTP header names" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :get)

      resource.get(Authorization: "Bearer token", content_type: :json, accept: :json)

      expect(fake_request.headers).to eq(
        "Authorization" => "Bearer token",
        "Content-Type"  => "application/json",
        "Accept"        => "application/json"
      )
    end

    it "extracts :params into the query string instead of sending it as a header" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :get)

      resource.get(Authorization: "Bearer token", params: { search: "jean" })

      expect(fake_request.params).to eq(search: "jean")
      expect(fake_request.headers).to eq("Authorization" => "Bearer token")
    end

    it "passes a string content_type through unchanged" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :get)

      resource.get(content_type: "application/x-www-form-urlencoded")

      expect(fake_request.headers["Content-Type"]).to eq "application/x-www-form-urlencoded"
    end

    it "does not set a body" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :get)

      resource.get({})

      expect(fake_request.body).to be_nil
    end

    it "wraps the Faraday response in a KeycloakAdmin::Response" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :get)

      expect(resource.get({})).to be_a KeycloakAdmin::Response
    end
  end

  describe "#post" do
    it "sends a pre-serialized string payload as the body unchanged" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :post)

      resource.post('{"username":"jean"}', content_type: :json)

      expect(fake_request.body).to eq '{"username":"jean"}'
      expect(fake_request.headers["Content-Type"]).to eq "application/json"
    end

    it "form-encodes a Hash payload" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :post)

      resource.post({ email: "a@b.com", firstName: "Jean Yves" }, {})

      expect(fake_request.body).to eq "email=a%40b.com&firstName=Jean+Yves"
    end

    it "stamps Content-Type: application/x-www-form-urlencoded for a Hash payload when none was set" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :post)

      resource.post({ id: "42" }, {})

      expect(fake_request.headers["Content-Type"]).to eq "application/x-www-form-urlencoded"
    end

    it "does not override an explicit Content-Type for a Hash payload" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users")
      stub_connection(resource, :post)

      resource.post({ id: "42" }, content_type: "application/vnd.custom+form")

      expect(fake_request.headers["Content-Type"]).to eq "application/vnd.custom+form"
    end
  end

  describe "#delete" do
    it "sends no body and only the given headers" do
      resource = KeycloakAdmin::Resource.new("http://example.com/users/1")
      stub_connection(resource, :delete)

      resource.delete(Authorization: "Bearer token")

      expect(fake_request.body).to be_nil
      expect(fake_request.headers).to eq("Authorization" => "Bearer token")
    end
  end

  describe ".execute (RestClient::Request.execute equivalent)" do
    it "dispatches an arbitrary method with a payload, including DELETE with a body" do
      resource_instance = KeycloakAdmin::Resource.new("http://example.com/mappings")
      allow(KeycloakAdmin::Resource).to receive(:new).and_return(resource_instance)
      stub_connection(resource_instance, :delete)

      KeycloakAdmin::Resource.execute(
        method: :delete,
        url: "http://example.com/mappings",
        payload: '[{"id":"1"}]',
        headers: { content_type: :json }
      )

      expect(fake_request.body).to eq '[{"id":"1"}]'
      expect(fake_request.headers["Content-Type"]).to eq "application/json"
    end

    it "forwards non-method/url/payload/headers keys as connection options" do
      resource_instance  = KeycloakAdmin::Resource.new("http://example.com/x")
      expected_options   = { timeout: 5 }
      stub_connection(resource_instance, :get)
      expect(KeycloakAdmin::Resource).to receive(:new).with("http://example.com/x", expected_options).and_return(resource_instance)

      KeycloakAdmin::Resource.execute(method: :get, url: "http://example.com/x", headers: {}, timeout: 5)
    end
  end

  describe ".put (RestClient.put shorthand)" do
    it "posts without requiring any connection options" do
      resource_instance = KeycloakAdmin::Resource.new("http://example.com/x")
      allow(KeycloakAdmin::Resource).to receive(:new).and_return(resource_instance)
      stub_connection(resource_instance, :put)

      KeycloakAdmin::Resource.put("http://example.com/x", "body", {})

      expect(fake_request.body).to eq "body"
    end
  end
end
