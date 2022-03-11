RSpec.describe KeycloakAdmin::ProtocolMapperRepresentation do
  describe "#to_json" do
    before(:each) do
      @mapper = KeycloakAdmin::ProtocolMapperRepresentation.from_hash(
        {
          "id" => "hello",
          "name" => "abcd",
          "protocol" => "openid-connect",
          "protocolMapper" => "oidc-hardcoded-claim-mapper",
          "consentRequired" => false,
          "config" => {
            "claim.value" => "123456",
            "userinfo.token.claim" => "false",
            "id.token.claim" => "false",
            "access.token.claim" => "true",
            "claim.name" => "abcd",
            "jsonType.label" => "String",
            "access.tokenResponse.claim" => "false"
          }
        }
      )
    end

    it "can convert to json" do
      expect(@mapper.to_json).to eq "{\"id\":\"hello\",\"config\":{\"claim.value\":\"123456\",\"userinfo.token.claim\":\"false\",\"id.token.claim\":\"false\",\"access.token.claim\":\"true\",\"claim.name\":\"abcd\",\"jsonType.label\":\"String\",\"access.tokenResponse.claim\":\"false\"},\"name\":\"abcd\",\"protocol\":\"openid-connect\",\"protocolMapper\":\"oidc-hardcoded-claim-mapper\"}"
    end
  end

  describe "array#to_json" do
    before(:each) do
      @mapper = [
        KeycloakAdmin::ProtocolMapperRepresentation.from_hash(
          {
            "id" => "hello",
            "name" => "abcd",
            "protocol" => "openid-connect",
            "protocolMapper" => "oidc-hardcoded-claim-mapper",
            "consentRequired" => false,
            "config" => {
              "claim.value" => "123456",
              "userinfo.token.claim" => "false",
              "id.token.claim" => "false",
              "access.token.claim" => "true",
              "claim.name" => "abcd",
              "jsonType.label" => "String",
              "access.tokenResponse.claim" => "false"
            }
          }
        )
      ]
    end

    it "can convert to json" do
      expect(@mapper.to_json).to eq "[{\"id\":\"hello\",\"config\":{\"claim.value\":\"123456\",\"userinfo.token.claim\":\"false\",\"id.token.claim\":\"false\",\"access.token.claim\":\"true\",\"claim.name\":\"abcd\",\"jsonType.label\":\"String\",\"access.tokenResponse.claim\":\"false\"},\"name\":\"abcd\",\"protocol\":\"openid-connect\",\"protocolMapper\":\"oidc-hardcoded-claim-mapper\"}]"
    end
  end
end
