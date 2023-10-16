RSpec.describe KeycloakAdmin::RealmClient do

  let(:client_id)           { "admin-cli" }
  let(:client_secret)       { "aaaaaaaa" }
  let(:client_realm_name)   { "master2" }
  let(:use_service_account) { true }
  let(:username)            { "a" }
  let(:password)            { "b" }
  let(:rest_client_options) { {timeout: 10 }

  before(:each) do
    @configuration                     = KeycloakAdmin::Configuration.new
    @configuration.server_url          = "http://auth.service.io/auth"
    @configuration.server_domain       = "auth.service.io"
    @configuration.client_id           = client_id
    @configuration.client_secret       = client_secret
    @configuration.client_realm_name   = client_realm_name
    @configuration.use_service_account = use_service_account
    @configuration.username            = username
    @configuration.password            = password
    @configuration.rest_client_options = rest_client_options
  end

  describe "#headers_for_token_retrieval" do
    before(:each) do
      @headers = @configuration.headers_for_token_retrieval
    end
    
    context "when use_service_account is false" do
      let(:use_service_account) { false }
      it "returns an empty hash" do 
        expect(@headers).to be_empty
      end
    end

    context "when use_service_account is true" do
      let(:use_service_account) { true }
      it "returns a single element" do
        expect(@headers.size).to eq 1
      end

      it "returns the Authorization Key" do
        expect(@headers.has_key?(:Authorization)).to be true
      end

      it "returns a Basic Authorization Key" do
        expect(@headers[:Authorization]).to start_with "Basic"
      end

      context "client_id='a' and client_secret='b'" do
        let(:client_id)           { "a" }
        let(:client_secret)       { "b" }

        it "returns a Basic Authorization = 'Basic YTpi'" do
          expect(@headers[:Authorization]).to eq "Basic YTpi"
        end
      end

      context "client_id='365e3c66-fd0f-11e7-8be5-0ed5f89f718b' and client_secret='411e6f9a-fd0f-11e7-8be5-0ed5f89f718b'" do
        let(:client_id)           { "365e3c66-fd0f-11e7-8be5-0ed5f89f718b" }
        let(:client_secret)       { "411e6f9a-fd0f-11e7-8be5-0ed5f89f718b" }

        it "returns a Basic Authorization = 'Basic MzY1ZTNjNjYtZmQwZi0xMWU3LThiZTUtMGVkNWY4OWY3MThiOjQxMWU2ZjlhLWZkMGYtMTFlNy04YmU1LTBlZDVmODlmNzE4Yg=='" do
          expect(@headers[:Authorization]).to eq "Basic MzY1ZTNjNjYtZmQwZi0xMWU3LThiZTUtMGVkNWY4OWY3MThiOjQxMWU2ZjlhLWZkMGYtMTFlNy04YmU1LTBlZDVmODlmNzE4Yg=="
        end
      end

    end
  end

  describe "#body_for_token_retrieval" do
    before(:each) do
      @body = @configuration.body_for_token_retrieval
    end
    context "when use_service_account is false" do
      let(:use_service_account) { false }
      it "returns a hash of 5 elements" do
        expect(@body.size).to eq 5
      end

      it "returns a hash containing the username" do
        expect(@body[:username]).to eq username
      end

      it "returns a hash containing the password" do
        expect(@body[:password]).to eq password
      end

      it "returns a hash containing the grant_type 'password'" do
        expect(@body[:grant_type]).to eq "password"
      end

      it "returns a hash containing the client_id" do
        expect(@body[:client_id]).to eq client_id
      end

      it "returns a hash containing the client_secret" do
        expect(@body[:client_secret]).to eq client_secret
      end
    end

    context "when use_service_account is true" do
      let(:use_service_account) { true }
      it "returns a hash of 1 element" do
        expect(@body.size).to eq 1
      end

      it "returns a hash containing the grant_type" do
        expect(@body[:grant_type]).to eq "client_credentials"
      end
    end
  end
end
