# frozen_string_literal: true
RSpec.describe KeycloakAdmin::Response do
  def fake_faraday_response(status: 200, body: "", headers: {}, reason_phrase: "OK")
    double(status: status, body: body, headers: headers, reason_phrase: reason_phrase)
  end

  describe "body-as-string behavior (RestClient::Response was a String subclass)" do
    it "behaves like the raw body string" do
      response = KeycloakAdmin::Response.new(fake_faraday_response(body: '{"a":1}'))
      expect(response).to eq '{"a":1}'
      expect(JSON.parse(response)).to eq({ "a" => 1 })
    end

    it "supports String methods relied on by callers, e.g. #to_i" do
      response = KeycloakAdmin::Response.new(fake_faraday_response(body: "42"))
      expect(response.to_i).to eq 42
    end

    it "exposes #body returning the same content" do
      response = KeycloakAdmin::Response.new(fake_faraday_response(body: "hello"))
      expect(response.body).to eq "hello"
    end
  end

  describe "#status / #code / #reason_phrase" do
    it "exposes the HTTP status" do
      response = KeycloakAdmin::Response.new(fake_faraday_response(status: 201))
      expect(response.status).to eq 201
      expect(response.code).to eq 201
    end

    it "exposes the reason phrase" do
      response = KeycloakAdmin::Response.new(fake_faraday_response(reason_phrase: "Created"))
      expect(response.reason_phrase).to eq "Created"
    end
  end

  describe "#headers" do
    it "symbolizes header names the way RestClient did (downcased, dash to underscore)" do
      response = KeycloakAdmin::Response.new(fake_faraday_response(headers: { "Location" => "/users/42", "Content-Type" => "application/json" }))
      expect(response.headers[:location]).to eq "/users/42"
      expect(response.headers[:content_type]).to eq "application/json"
    end

    it "splits a single Set-Cookie header into a one-element array" do
      response = KeycloakAdmin::Response.new(fake_faraday_response(headers: { "Set-Cookie" => "a=1; Path=/" }))
      expect(response.headers[:set_cookie]).to eq ["a=1; Path=/"]
    end

    it "splits multiple Set-Cookie headers joined by Faraday's net_http adapter" do
      joined = "KEYCLOAK_SESSION=abc; Path=/, KEYCLOAK_IDENTITY=def; Path=/, AUTH_SESSION_ID=ghi; Path=/"
      response = KeycloakAdmin::Response.new(fake_faraday_response(headers: { "Set-Cookie" => joined }))
      expect(response.headers[:set_cookie]).to eq [
        "KEYCLOAK_SESSION=abc; Path=/",
        "KEYCLOAK_IDENTITY=def; Path=/",
        "AUTH_SESSION_ID=ghi; Path=/"
      ]
    end

    it "does not split on a comma embedded in a cookie's own Expires attribute" do
      joined = "a=1; Expires=Wed, 09 Jun 2027 10:18:14 GMT; Path=/, b=2; Path=/"
      response = KeycloakAdmin::Response.new(fake_faraday_response(headers: { "Set-Cookie" => joined }))
      expect(response.headers[:set_cookie]).to eq [
        "a=1; Expires=Wed, 09 Jun 2027 10:18:14 GMT; Path=/",
        "b=2; Path=/"
      ]
    end
  end
end
