RSpec.describe KeycloakAdmin::IdentityProviderMapperRepresentation do
  describe "#to_json" do
    before(:each) do
      @mapper = KeycloakAdmin::IdentityProviderMapperRepresentation.from_hash(
        {
          "id" => "91895ce9-b225-4274-993e-c8e6b8e490f0",
          "name" => "IDP",
          "identityProviderAlias" => "test",
          "identityProviderMapper" => "hardcoded-attribute-idp-mapper",
          "config" => {
            "syncMode" => "INHERIT",
            "attribute.value" => "test",
            "attributes" => "[]",
            "attribute" => "keycloak.idp"
          }
        }
      )
    end

    it "can convert to json" do
      expect(@mapper.to_json).to eq "{\"id\":\"91895ce9-b225-4274-993e-c8e6b8e490f0\",\"name\":\"IDP\",\"identityProviderAlias\":\"test\",\"identityProviderMapper\":\"hardcoded-attribute-idp-mapper\",\"config\":{\"syncMode\":\"INHERIT\",\"attribute.value\":\"test\",\"attributes\":\"[]\",\"attribute\":\"keycloak.idp\"}}"
    end
  end
end
