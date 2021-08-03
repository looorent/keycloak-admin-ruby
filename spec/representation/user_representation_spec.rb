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
      expect(@user.to_json).to eq '{"id":null,"createdTimestamp":1559836000,"origin":null,"username":"test_username","email":null,"enabled":true,"emailVerified":null,"firstName":null,"lastName":null,"attributes":null,"requiredActions":[],"totp":false,"credentials":[],"federatedIdentities":[]}'
    end
  end
end
