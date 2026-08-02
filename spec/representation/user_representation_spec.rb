RSpec.describe KeycloakAdmin::UserRepresentation do
  describe "#to_json" do
    before(:each) do
      @user = KeycloakAdmin::UserRepresentation.from_hash(
        "username" => "test_username",
        "createdTimestamp" => Time.at(1559836000).to_i,
        "enabled" => true
      )
    end

    it "can convert to json" do
      expect(@user.to_json).to eq '{"createdTimestamp":1559836000,"username":"test_username","enabled":true,"requiredActions":[],"totp":false,"credentials":[],"federatedIdentities":[]}'
    end
  end
end
