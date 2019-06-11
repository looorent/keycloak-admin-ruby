RSpec.describe KeycloakAdmin::UserResource do
  describe "#resource_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { "95985b21-d884-4bbd-b852-cb8cd365afc2" }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).user(user_id).resource_url
    end

    it "return a proper url" do
      expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/users/95985b21-d884-4bbd-b852-cb8cd365afc2"
    end
  end
end
