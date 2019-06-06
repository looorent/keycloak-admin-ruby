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
      allow_any_instance_of(RestClient::Resource).to receive(:post)
    end

    it "saves a user" do
      expect(@user_client.save(user)).to eq user
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users", rest_client_options).and_call_original

      expect(@user_client.save(user)).to eq user
    end
  end

  describe "#get" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"username":"test_username","createdTimestamp":1559347200}'
    end

    it "parses the response" do
      user = @user_client.get('test_user_id')
      expect(user.username).to eq 'test_username'
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user_id", rest_client_options).and_call_original

      user = @user_client.get('test_user_id')
      expect(user.username).to eq 'test_username'
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
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '[{"username":"test_username","createdTimestamp":1559347200}]'
    end

    it "finds a user" do
      users = @user_client.search("test_username")
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users", rest_client_options).and_call_original

      users = @user_client.search("test_username")
      expect(users.length).to eq 1
      expect(users[0].username).to eq "test_username"
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @user_client = KeycloakAdmin.realm(realm_name).users

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete)
    end

    it "does not fail" do
      expect(@user_client.delete('test_user_id')).to be_truthy
    end

    it "passes rest client options" do
      rest_client_options = {verify_ssl: OpenSSL::SSL::VERIFY_NONE}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/users/test_user_id", rest_client_options).and_call_original

      @user_client.delete('test_user_id')
    end
  end

  def stub_token_client
    allow_any_instance_of(KeycloakAdmin::TokenClient).to receive(:get).and_return KeycloakAdmin::TokenRepresentation.new(
      'test_access_token', 'token_type', 'expires_in', 'refresh_token',
      'refresh_expires_in', 'id_token', 'not_before_policy', 'session_state'
    )
  end
end
