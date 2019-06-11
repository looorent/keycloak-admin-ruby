RSpec.describe KeycloakAdmin::GroupResource do
  describe "#resource_url" do
    let(:realm_name) { "valid-realm" }
    let(:group_id)   { "95985b21-d884-4bbd-b852-cb8cd365afc2" }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).group(group_id).resource_url
    end

    it "return a proper url" do
      expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/groups/95985b21-d884-4bbd-b852-cb8cd365afc2"
    end
  end
end
