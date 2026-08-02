RSpec.describe KeycloakAdmin::TokenClient do
  describe "#initialize" do
    let(:realm_name) { nil }
    before(:each) do
      @realm = KeycloakAdmin.realm(realm_name)
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master" }
      it "does not raise any error" do
        expect {
          @realm.users
        }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "raises any error" do
        expect {
          @realm.users
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#users_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).users.users_url(user_id)
    end

    context "when user_id is not defined" do
      let(:user_id) { nil }
      it "return a proper url without user id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users"
      end
    end

    context "when user_id is defined" do
      let(:user_id) { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "return a proper url with the user id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users/95985b21-d884-4bbd-b852-cb8cd365afc2"
      end
    end
  end

  describe "#reset_password_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { nil }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).users
    end

    context "when user_id is not defined" do
      let(:user_id) { nil }
      it "raises an error" do
        expect {
          @client.reset_password_url(user_id)
        }.to raise_error(ArgumentError)
      end
    end

    context "when user_id is defined" do
      let(:user_id) { 42 }
      it "return a proper url" do
        expect(@client.reset_password_url(user_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users/42/reset-password"
      end
    end
  end

  describe "#execute_actions_email_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { nil }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).users
    end

    context "when user_id is not defined" do
      let(:user_id) { nil }
      it "raises an error" do
        expect {
          @client.execute_actions_email_url(user_id)
        }.to raise_error(ArgumentError)
      end
    end

    context "when user_id is defined" do
      let(:user_id) { 42 }
      it "return a proper url" do
        expect(@client.execute_actions_email_url(user_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users/42/execute-actions-email"
      end
    end
  end

  describe "#impersonation_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { nil }

    before(:each) do
      @client = KeycloakAdmin.realm(realm_name).users
    end

    context "when user_id is not defined" do
      let(:user_id) { nil }
      it "raises an error" do
        expect {
          @client.impersonation_url(user_id)
        }.to raise_error(ArgumentError)
      end
    end

    context "when user_id is defined" do
      let(:user_id) { 42 }
      it "return a proper url" do
        expect(@client.impersonation_url(user_id)).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users/42/impersonation"
      end
    end
  end

  describe "#save" do
    let(:realm_name) { "valid-realm" }
    let(:user) { KeycloakAdmin::UserRepresentation.from_hash(
      "username" => "test_username",
      "createdTimestamp" => Time.now.to_i,
    )}

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
      allow_any_instance_of(KeycloakAdmin::Resource).to receive(:post)
    end

    it "saves a user" do
      expect(@user_client.save(user)).to eq user
    end

    it "passes rest client options" do
      faraday_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users", faraday_options, anything).and_call_original

      expect(@user_client.save(user)).to eq user
    end
  end

  describe "#get" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
      allow_any_instance_of(KeycloakAdmin::Resource).to receive(:get).and_return '{"username":"test_username","createdTimestamp":1559347200, "requiredActions":["CONFIGURE_TOTP"], "totp": true}'
    end

    it "parses the response" do
      user = @user_client.get('test_user_id')
      expect(user.username).to eq 'test_username'
    end

    it "passes rest client options" do
      faraday_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user_id", faraday_options, anything).and_call_original

      user = @user_client.get('test_user_id')
      expect(user.username).to eq 'test_username'
      expect(user.totp).to be true
      expect(user.required_actions).to eq ["CONFIGURE_TOTP"]
    end
  end

  describe "#search" do
    let(:realm_name) { "valid-realm" }
    let(:user) { KeycloakAdmin::UserRepresentation.from_hash(
      "username" => "test_username",
      "createdTimestamp" => Time.now.to_i,
    )}

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
      allow_any_instance_of(KeycloakAdmin::Resource).to receive(:get).and_return '[{"username":"test_username","createdTimestamp":1559347200}]'
    end

    it "finds a user using a string" do
      users = @user_client.search("test_username")
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end

    it "finds a user using nil does not fail" do
      users = @user_client.search(nil)
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end

    it "finds a user using a hash" do
      users = @user_client.search({ search: "test_username"})
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end

    it "passes rest client options" do
      faraday_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users", faraday_options, anything).and_call_original

      users = @user_client.search("test_username")
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }
    let(:user) { KeycloakAdmin::UserRepresentation.from_hash(
      "username" => "test_username",
      "createdTimestamp" => Time.now.to_i,
    )}

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
      allow_any_instance_of(KeycloakAdmin::Resource).to receive(:get).and_return '[{"username":"test_username","createdTimestamp":1559347200}]'
    end

    it "lists users" do
      users = @user_client.list
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end

    it "passes rest client options" do
      faraday_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users", faraday_options, anything).and_call_original

      users = @user_client.list
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
      allow_any_instance_of(KeycloakAdmin::Resource).to receive(:delete)
    end

    it "does not fail" do
      expect(@user_client.delete('test_user_id')).to be_truthy
    end

    it "passes rest client options" do
      faraday_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user_id", faraday_options, anything).and_call_original

      @user_client.delete('test_user_id')
    end
  end

  describe '#update' do
    let(:realm_name) { 'valid-realm' }
    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
    end

    context 'when user_id is defined' do
      let(:user_id) { '95985b21-d884-4bbd-b852-cb8cd365afc2' }
      let(:url)     { "http://auth.service.io/auth/admin/realms/valid-realm/users/#{user_id}" }

      it 'updates the user details' do
        request = stub_request(:put, url).with(
          body:    '{"firstName":"Test","enabled":false}',
          headers: {
            "Authorization" => "Bearer test_access_token",
            "Content-Type"  => "application/json",
            "Accept"        => "application/json"
          }
        ).to_return(status: 204)

        @user_client.update(user_id, { firstName: 'Test', enabled: false })

        expect(request).to have_been_requested
      end
    end

    context 'when user_id is not defined' do
      let(:user_id) { nil }

      it 'raise argument error' do
        expect { @user_client.update(user_id, { firstName: 'Test', enabled: false }) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#sessions' do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users
      stub_token_client
      allow_any_instance_of(KeycloakAdmin::Resource).to receive(:get).and_return '[{"id":"95985b21-d884-4bbd-b852-dsfsdfsd","username":"test_username", "ip_address":"0.0.0.0"}]'
    end

    context 'when user_id is defined' do
      let(:user_id) { '95985b21-d884-4bbd-b852-cb8cd365afc2' }
      it 'returns list of active sessions' do
        response = @user_client.sessions(user_id)
        expect(response[0].id).to eq '95985b21-d884-4bbd-b852-dsfsdfsd'
      end
    end

    context 'when user_id is not defined' do
      let(:user_id) { nil }
      it 'raise argument error' do
        expect { @user_client.sessions(user_id) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#logout' do
    let(:realm_name) { 'valid-realm' }

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users
      stub_token_client
      allow(KeycloakAdmin::Resource).to receive(:execute)
    end

    context 'when user_id is defined' do
      let(:user_id) { '95985b21-d884-4bbd-b852-cb8cd365afc2' }
      it 'logout user and return true' do
        expect(@user_client.logout(user_id)).to be_truthy
      end
    end

    context 'when user_id is not defined' do
      let(:user_id) { nil }
      it 'raise argument error' do
        expect { @user_client.logout(user_id) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#credentials' do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users
      stub_token_client
      json_payload = <<-'payload'
        [
          {
            "id": "2ff4b4d0-fd72-4c6e-9684-02ab337687c2",
            "type": "password",
            "userLabel": "My password",
            "createdDate": 1767604673211,
            "credentialData": "{\"hashIterations\":5,\"algorithm\":\"argon2\",\"additionalParameters\":{\"hashLength\":[\"32\"],\"memory\":[\"7168\"],\"type\":[\"id\"],\"version\":[\"1.3\"],\"parallelism\":[\"1\"]}}"
          },
          {
            "id": "34389672-9356-4154-9ed6-6c212b869010",
            "type": "otp",
            "userLabel": "Smartphone",
            "createdDate": 1767605202060,
            "credentialData": "{\"subType\":\"totp\",\"digits\":6,\"counter\":0,\"period\":30,\"algorithm\":\"HmacSHA1\"}"
          }
        ]
      payload
      allow_any_instance_of(KeycloakAdmin::Resource).to receive(:get).and_return json_payload
    end

    context 'when user_id is defined' do
      let(:user_id) { '95985b21-d884-4bbd-b852-cb8cd365afc2' }
      it 'returns list of credentials' do
        response = @user_client.credentials(user_id)
        expect(response.size).to eq 2
        expect(response[0].id).to eq "2ff4b4d0-fd72-4c6e-9684-02ab337687c2"
        expect(response[1].id).to eq "34389672-9356-4154-9ed6-6c212b869010"
      end
    end

    context 'when user_id is not defined' do
      let(:user_id) { nil }
      it 'raise argument error' do
        expect { @user_client.credentials(user_id) }.to raise_error(ArgumentError)
      end
    end
  end
end

RSpec.describe "KeycloakAdmin::UserClient#execute_actions_email" do
  let(:realm_name) { "valid-realm" }
  let(:user_id)    { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
  let(:base_url)   { "http://auth.service.io/auth/admin/realms/valid-realm/users/#{user_id}/execute-actions-email" }
  let(:user_client) { KeycloakAdmin.realm(realm_name).users }

  before(:each) { stub_token_client }

  it "sends the actions as the body" do
    request = stub_request(:put, base_url).with(body: '["UPDATE_PASSWORD"]').to_return(status: 204)

    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"])

    expect(request).to have_been_requested
  end

  it "omits the query string entirely when no optional parameter is given" do
    requested_uri = nil
    stub_request(:put, /execute-actions-email/).with { |req| requested_uri = req.uri.to_s; true }.to_return(status: 204)

    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"])

    expect(requested_uri).to_not include "?"
  end

  # Regression: this used ActiveSupport's Numeric#seconds, which raised NoMethodError outside Rails.
  it "sends the lifespan in seconds without depending on ActiveSupport" do
    request = stub_request(:put, base_url).with(query: {"lifespan" => "300"}).to_return(status: 204)

    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"], 300)

    expect(request).to have_been_requested
  end

  it "accepts anything that responds to to_i as a lifespan" do
    request = stub_request(:put, base_url).with(query: {"lifespan" => "300"}).to_return(status: 204)

    duration = double("ActiveSupport::Duration", to_i: 300)
    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"], duration)

    expect(request).to have_been_requested
  end

  # Regression: redirect_uri was interpolated raw, so its own '?'/'&' forged extra parameters.
  it "percent-encodes a redirect_uri that carries its own query string" do
    redirect_uri = "https://app.example.com/landing?next=/home&flag=a b"
    request = stub_request(:put, base_url).with(
      query: {"client_id" => "my-app", "redirect_uri" => redirect_uri}
    ).to_return(status: 204)

    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"], nil, redirect_uri, "my-app")

    expect(request).to have_been_requested
  end

  it "sends client_id, redirect_uri and lifespan together" do
    request = stub_request(:put, base_url).with(
      query: {"client_id" => "my-app", "redirect_uri" => "https://app.example.com/cb", "lifespan" => "60"}
    ).to_return(status: 204)

    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"], 60, "https://app.example.com/cb", "my-app")

    expect(request).to have_been_requested
  end

  it "rejects a redirect_uri given without a client_id" do
    expect {
      user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"], nil, "https://app.example.com/cb")
    }.to raise_error(ArgumentError, "client_id must be defined")
  end

  it "returns the user id" do
    stub_request(:put, /execute-actions-email/).to_return(status: 204)

    expect(user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"])).to eq user_id
  end

  # Regression: this went through Resource.put, whose signature hardcoded {} as the connection
  # options, so this was the one call in the gem that ran with no timeout and ignored any
  # configured SSL or proxy settings.
  it "passes rest client options" do
    faraday_options = {request: {timeout: 10}}
    allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options
    stub_request(:put, /execute-actions-email/).to_return(status: 204)

    expect(KeycloakAdmin::Resource).to receive(:new).with(base_url, faraday_options, anything).and_call_original

    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"])
  end

  it "passes rest client options when a query string is appended" do
    faraday_options = {request: {timeout: 10}}
    allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options
    stub_request(:put, /execute-actions-email/).to_return(status: 204)

    expect(KeycloakAdmin::Resource).to receive(:new).with(
      "#{base_url}?lifespan=300", faraday_options, anything).and_call_original

    user_client.execute_actions_email(user_id, ["UPDATE_PASSWORD"], 300)
  end

  describe "#forgot_password" do
    it "delegates to execute_actions_email with UPDATE_PASSWORD" do
      request = stub_request(:put, base_url)
        .with(body: '["UPDATE_PASSWORD"]', query: {"lifespan" => "120"}).to_return(status: 204)

      user_client.forgot_password(user_id, 120)

      expect(request).to have_been_requested
    end
  end
end

RSpec.describe "KeycloakAdmin::UserClient error handling" do
  let(:realm_name)  { "valid-realm" }
  let(:user_id)     { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
  let(:group_id)    { "8a1e1b1c-3b28-4a3a-9d0f-1a2b3c4d5e6f" }
  let(:user_url)    { "http://auth.service.io/auth/admin/realms/valid-realm/users/#{user_id}" }
  let(:group_url)   { "#{user_url}/groups/#{group_id}" }
  let(:user_client) { KeycloakAdmin.realm(realm_name).users }

  before(:each) { stub_token_client }

  describe "#add_group" do
    it "adds the user to the group" do
      request = stub_request(:put, group_url).with(body: "{}").to_return(status: 204)

      user_client.add_group(user_id, group_id)

      expect(request).to have_been_requested
    end
  end

  describe "#remove_group" do
    it "removes the user from the group" do
      request = stub_request(:delete, group_url).to_return(status: 204)

      user_client.remove_group(user_id, group_id)

      expect(request).to have_been_requested
    end
  end

  {
    "#update"       => [:put,    ->(c, u, g) { c.update(u, {enabled: false}) }],
    "#add_group"    => [:put,    ->(c, u, g) { c.add_group(u, g) }],
    "#remove_group" => [:delete, ->(c, u, g) { c.remove_group(u, g) }]
  }.each do |method_name, (verb, call)|
    describe method_name do
      let(:url) { method_name == "#update" ? user_url : group_url }

      it "raises a typed KeycloakAdmin error on 404" do
        stub_request(verb, url).to_return(status: 404, body: "not found")

        expect { call.call(user_client, user_id, group_id) }
          .to raise_error(KeycloakAdmin::NotFoundError) { |error|
            expect(error.status).to eq 404
            expect(error.body).to eq "not found"
          }
      end

      it "raises a typed KeycloakAdmin error on 500" do
        stub_request(verb, url).to_return(status: 500, body: "boom")

        expect { call.call(user_client, user_id, group_id) }.to raise_error(KeycloakAdmin::ServerError)
      end

      it "drops the cached token and replays once on 401" do
        token_calls = 0
        allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get) do
          token_calls += 1
          KeycloakAdmin::TokenRepresentation.new(
            "test_access_token", "token_type", 3600, "refresh_token",
            "refresh_expires_in", "id_token", "not_before_policy", "session_state"
          )
        end
        request = stub_request(verb, url).to_return({status: 401, body: "expired"}, {status: 204})

        call.call(user_client, user_id, group_id)

        expect(request).to have_been_requested.twice
        expect(token_calls).to eq 2
      end

      it "gives up after a single replay" do
        allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get).and_return(
          KeycloakAdmin::TokenRepresentation.new(
            "test_access_token", "token_type", 3600, "refresh_token",
            "refresh_expires_in", "id_token", "not_before_policy", "session_state"
          )
        )
        request = stub_request(verb, url).to_return(status: 401, body: "still expired")

        expect { call.call(user_client, user_id, group_id) }.to raise_error(KeycloakAdmin::UnauthorizedError)
        expect(request).to have_been_requested.twice
      end
    end
  end
end

RSpec.describe "KeycloakAdmin::UserClient#create!" do
  let(:realm_name)  { "valid-realm" }
  let(:users_url)   { "http://auth.service.io/auth/admin/realms/valid-realm/users" }
  let(:new_id)      { "0f6b1e4c-8b7a-4f21-9c3d-2e5a7b9c1d3f" }
  let(:user_client) { KeycloakAdmin.realm(realm_name).users }

  before(:each) { stub_token_client }

  def stub_creation(location: "#{users_url}/#{new_id}", status: 201)
    stub_request(:post, users_url).to_return(status: status, headers: location ? {"Location" => location} : {})
  end

  def stub_fetch(id: new_id, body: nil)
    stub_request(:get, "#{users_url}/#{id}").to_return(
      status: 200,
      body: (body || {"id" => id, "username" => "pioupioux", "email" => "pioupioux@email.com"}).to_json
    )
  end

  it "returns the created user" do
    stub_creation
    stub_fetch

    user = user_client.create!("pioupioux", "pioupioux@email.com", "acme0", true, "en")

    expect(user).to be_a KeycloakAdmin::UserRepresentation
    expect(user.id).to eq new_id
    expect(user.username).to eq "pioupioux"
  end

  it "reads the new id from the Location header instead of searching for it" do
    stub_creation
    fetch  = stub_fetch
    search = stub_request(:get, /users\?/)

    user_client.create!("pioupioux", "pioupioux@email.com", "acme0", true, "en")

    expect(fetch).to have_been_requested
    expect(search).to_not have_been_requested
  end

  # Regression: create! used to return search(email).first, and Keycloak's `search` parameter
  # matches a substring of the username, email, first name or last name. Creating
  # "pioupioux@email.com" while "vieuxpioupioux@email.com" already existed returned the
  # pre-existing user, so the caller silently operated on somebody else's account.
  it "returns the new user even when another account matches the email as a substring" do
    stub_creation
    stub_fetch
    stub_request(:get, /users\?/).to_return(
      status: 200,
      body: [{"id" => "a-pre-existing-user", "email" => "vieuxpioupioux@email.com"}].to_json
    )

    user = user_client.create!("pioupioux", "pioupioux@email.com", "acme0", true, "en")

    expect(user.id).to eq new_id
  end

  it "sends the username, email and password" do
    request = stub_creation.with { |req|
      body = JSON.parse(req.body)
      body["username"] == "pioupioux" &&
        body["email"] == "pioupioux@email.com" &&
        body["credentials"].first["value"] == "acme0"
    }
    stub_fetch

    user_client.create!("pioupioux", "pioupioux@email.com", "acme0", true, "en")

    expect(request).to have_been_requested
  end

  it "raises when the creation is not answered with 201 Created" do
    stub_creation(status: 204, location: nil)

    expect { user_client.create!("pioupioux", "pioupioux@email.com", "acme0", true, "en") }
      .to raise_error(KeycloakAdmin::UnexpectedResponseError)
  end

  it "raises a typed error when the creation is rejected" do
    stub_request(:post, users_url).to_return(status: 409, body: "User exists with same username")

    expect { user_client.create!("pioupioux", "pioupioux@email.com", "acme0", true, "en") }
      .to raise_error(KeycloakAdmin::ConflictError)
  end
end
