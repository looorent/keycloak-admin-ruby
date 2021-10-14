RSpec.describe KeycloakAdmin::IdentityProviderRepresentation do
  describe "#from_hash" do
    before(:each) do
      json = <<-JSON
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
      JSON
      payload            = JSON.parse(json)
      @identity_provider = KeycloakAdmin::IdentityProviderRepresentation.from_hash(payload)
    end

    it "parses the alias" do
      expect(@identity_provider.alias).to eq "acme"
    end

    it "parses the display name" do
      expect(@identity_provider.display_name).to eq "ACME"
    end

    it "parses the internalId" do
      expect(@identity_provider.internal_id).to eq "20fea77e-ae3d-411e-9467-2b3a20cd3e6d"
    end

    it "parses the provider id" do
      expect(@identity_provider.provider_id).to eq "saml"
    end

    it "parses the enabled" do
      expect(@identity_provider.enabled).to eq true
    end

    it "parses the update_profile_first_login_mode" do
      expect(@identity_provider.update_profile_first_login_mode).to eq "on"
    end

    it "parses the trust_email" do
      expect(@identity_provider.trust_email).to eq true
    end

    it "parses the store_token" do
      expect(@identity_provider.store_token).to eq false
    end

    it "parses the add_read_token_role_on_create" do
      expect(@identity_provider.add_read_token_role_on_create).to eq false
    end

    it "parses the authenticate_by_default" do
      expect(@identity_provider.authenticate_by_default).to eq false
    end

    it "parses the link_only" do
      expect(@identity_provider.link_only).to eq false
    end
    
    it "parses the first_broker_login_flow_alias" do
      expect(@identity_provider.first_broker_login_flow_alias).to eq "first broker login"
    end

    it "parses the configuration as a hash with camel properties" do
      expect(@identity_provider.configuration["hideOnLoginPage"]).to eq ""
      expect(@identity_provider.configuration["validateSignature"]).to eq "true"
      expect(@identity_provider.configuration["samlXmlKeyNameTranformer"]).to eq "KEY_ID"
      expect(@identity_provider.configuration["signingCertificate"]).to eq ""
      expect(@identity_provider.configuration["postBindingLogout"]).to eq "false"
      expect(@identity_provider.configuration["nameIDPolicyFormat"]).to eq "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
      expect(@identity_provider.configuration["postBindingResponse"]).to eq "true"
      expect(@identity_provider.configuration["backchannelSupported"]).to eq ""
      expect(@identity_provider.configuration["signatureAlgorithm"]).to eq "RSA_SHA256"
      expect(@identity_provider.configuration["wantAssertionsEncrypted"]).to eq "false"
      expect(@identity_provider.configuration["xmlSigKeyInfoKeyNameTransformer"]).to eq "CERT_SUBJECT"
      expect(@identity_provider.configuration["useJwksUrl"]).to eq "true"
      expect(@identity_provider.configuration["wantAssertionsSigned"]).to eq "true"
      expect(@identity_provider.configuration["postBindingAuthnRequest"]).to eq "true"
      expect(@identity_provider.configuration["forceAuthn"]).to eq ""
      expect(@identity_provider.configuration["wantAuthnRequestsSigned"]).to eq "true"
      expect(@identity_provider.configuration["singleSignOnServiceUrl"]).to eq "https://login.microsoftonline.com/test/saml2"
      expect(@identity_provider.configuration["addExtensionsElementWithKeyInfo"]).to eq "false"
    end
  end
end
