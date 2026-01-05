
RSpec.describe KeycloakAdmin::CredentialRepresentation do
  describe ".from_json" do
    it "parses a password" do
      json_payload = <<-'payload'
        {
          "id": "2ff4b4d0-fd72-4c6e-9684-02ab337687c2",
          "type": "password",
          "userLabel": "My password",
          "createdDate": 1767604673211,
          "credentialData": "{\"hashIterations\":5,\"algorithm\":\"argon2\",\"additionalParameters\":{\"hashLength\":[\"32\"],\"memory\":[\"7168\"],\"type\":[\"id\"],\"version\":[\"1.3\"],\"parallelism\":[\"1\"]}}"
        }
      payload

      credential = described_class.from_json(json_payload)
      expect(credential).to be
      expect(credential).to be_a described_class
      expect(credential.id).to eq "2ff4b4d0-fd72-4c6e-9684-02ab337687c2"
      expect(credential.type).to eq "password"
      expect(credential.createdDate).to eq 1767604673211
      expect(credential.credentialData).to eq "{\"hashIterations\":5,\"algorithm\":\"argon2\",\"additionalParameters\":{\"hashLength\":[\"32\"],\"memory\":[\"7168\"],\"type\":[\"id\"],\"version\":[\"1.3\"],\"parallelism\":[\"1\"]}}"
      expect(credential.userLabel).to eq "My password"
      expect(credential.device).to be_nil
      expect(credential.value).to be_nil
      expect(credential.hashedSaltedValue).to be_nil
      expect(credential.salt).to be_nil
      expect(credential.hashIterations).to eq 5
      expect(credential.counter).to be_nil
      expect(credential.algorithm).to eq "argon2"
      expect(credential.digits).to be_nil
      expect(credential.period).to be_nil
      expect(credential.config).to be_nil
      expect(credential.temporary).to be_nil
    end

    it "parses an otp" do
      json_payload = <<-'payload'
        {
          "id": "34389672-9356-4154-9ed6-6c212b869010",
          "type": "otp",
          "userLabel": "Smartphone",
          "createdDate": 1767605202060,
          "credentialData": "{\"subType\":\"totp\",\"digits\":6,\"counter\":0,\"period\":30,\"algorithm\":\"HmacSHA1\"}"
        }
      payload

      credential = described_class.from_json(json_payload)
      expect(credential).to be
      expect(credential).to be_a described_class
      expect(credential.id).to eq "34389672-9356-4154-9ed6-6c212b869010"
      expect(credential.type).to eq "otp"
      expect(credential.createdDate).to eq 1767605202060
      expect(credential.credentialData).to eq "{\"subType\":\"totp\",\"digits\":6,\"counter\":0,\"period\":30,\"algorithm\":\"HmacSHA1\"}"
      expect(credential.userLabel).to eq "Smartphone"
      expect(credential.device).to be_nil
      expect(credential.value).to be_nil
      expect(credential.hashedSaltedValue).to be_nil
      expect(credential.salt).to be_nil
      expect(credential.hashIterations).to be_nil
      expect(credential.counter).to eq 0
      expect(credential.algorithm).to eq "HmacSHA1"
      expect(credential.digits).to eq 6
      expect(credential.period).to eq 30
      expect(credential.config).to be_nil
      expect(credential.temporary).to be_nil
    end
  end
end
