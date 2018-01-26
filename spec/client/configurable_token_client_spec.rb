RSpec.describe KeycloakAdmin::ConfigurableTokenClient do
  describe "#initialize" do
    context "when realm_name is defined" do
      let(:realm_name) { "master" }
      it "does not raise any error" do
        expect {
          KeycloakAdmin.realm(realm_name).configurable_token
        }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "raises any error" do
        expect {
          KeycloakAdmin.realm(realm_name).configurable_token
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#token_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).configurable_token.token_url
    end

    it "return a proper url with the realm name" do
      expect(@built_url).to eq "http://auth.service.io/auth/realms/valid-realm/configurable-token"
    end
  end
end
