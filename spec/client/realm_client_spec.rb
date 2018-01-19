RSpec.describe KeycloakAdmin::RealmClient do
  describe "#realm_url" do

    let(:realm_name) { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).realm_url
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master2" }
      it "return a proper url with realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/realms/master2"
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "return a proper url without realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/realms"
      end
    end
  end

  describe "#admin_realm_url" do

    let(:realm_name) { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).realm_admin_url
    end

    context "when realm_name is defined" do
      let(:realm_name) { "master2" }
      it "return a proper url with realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/master2"
      end
    end

    context "when realm_name is not defined" do
      let(:realm_name) { nil }
      it "return a proper url without realm_name" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms"
      end
    end
  end
end
