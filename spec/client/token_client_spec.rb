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
          @realm.token
        }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "raises any error" do
        expect {
          @realm.token
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#token_url" do
    let(:realm_name) { "valid-realm" }
    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).token.token_url
    end

    it "return a proper url" do
      expect(@built_url).to eq "http://auth.service.io/auth/realms/valid-realm/protocol/openid-connect/token"
    end
  end
end
