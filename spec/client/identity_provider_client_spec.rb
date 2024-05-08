RSpec.describe KeycloakAdmin::IdentityProviderClient do
  describe "#identity_providers_url" do
    let(:realm_name)  { "valid-realm" }
    let(:provider_id) { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).identity_providers.identity_providers_url(provider_id)
    end

    context "when provider_id is not defined" do
      let(:provider_id) { nil }
      it "returns a proper url without provider id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/identity-provider/instances"
      end
    end

    context "when provider_id is defined" do
      let(:provider_id) { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "returns a proper url with the provider id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/identity-provider/instances/95985b21-d884-4bbd-b852-cb8cd365afc2"
      end
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }
    let(:json_response) do
      <<-JSON
      [
        {
          "alias": "acme",
          "displayName": "ACME",
          "internalId": "20fea77e-ae3d-411e-9467-2b3a20cd3e6d",
          "providerId": "saml",
          "enabled": true,
          "updateProfileFirstLoginMode": "on",
          "trustEmail": true,
          "storeToken": false,
          "addReadTokenRoleOnCreate": false,
          "authenticateByDefault": false,
          "linkOnly": false,
          "firstBrokerLoginFlowAlias": "first broker login",
          "config": {
            "hideOnLoginPage": "",
            "validateSignature": "true",
            "samlXmlKeyNameTranformer": "KEY_ID",
            "signingCertificate": "",
            "postBindingLogout": "false",
            "nameIDPolicyFormat": "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
            "postBindingResponse": "true",
            "backchannelSupported": "",
            "signatureAlgorithm": "RSA_SHA256",
            "wantAssertionsEncrypted": "false",
            "xmlSigKeyInfoKeyNameTransformer": "CERT_SUBJECT",
            "useJwksUrl": "true",
            "wantAssertionsSigned": "true",
            "postBindingAuthnRequest": "true",
            "forceAuthn": "",
            "wantAuthnRequestsSigned": "true",
            "singleSignOnServiceUrl": "https://login.microsoftonline.com/test/saml2",
            "addExtensionsElementWithKeyInfo": "false"
          }
        }
      ]
      JSON
    end
    before(:each) do
      @identity_provider_client = KeycloakAdmin.realm(realm_name).identity_providers

      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_response
    end

    it "lists identity providers" do
      identity_providers = @identity_provider_client.list
      expect(identity_providers.length).to eq 1
      expect(identity_providers[0].alias).to eq "acme"
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/identity-provider/instances", rest_client_options).and_call_original

      identity_providers = @identity_provider_client.list
      expect(identity_providers.length).to eq 1
      expect(identity_providers[0].alias).to eq "acme"
    end
  end
end
