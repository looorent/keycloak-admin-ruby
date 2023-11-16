RSpec.describe KeycloakAdmin::ClientRepresentation do
  describe "#to_json" do
    before(:each) do
      @client = KeycloakAdmin::ClientRepresentation.from_hash(
        {
          "id" => "c9104bc7-04d8-4348-b4df-8d883f9f6095",
          "clientId" => "clien-test",
          "name" => "Client TEST",
          "description" => "Test to parse a client repsentation",
          "surrogateAuthRequired" => false,
          "enabled" => true,
          "alwaysDisplayInConsole" => false,
          "clientAuthenticatorType" => "client-secret",
          "redirectUris" => [],
          "webOrigins" => [],
          "notBefore" => 0,
          "bearerOnly" => false,
          "consentRequired" => false,
          "standardFlowEnabled" => false,
          "implicitFlowEnabled" => false,
          "directAccessGrantsEnabled" => false,
          "serviceAccountsEnabled" => true,
          "publicClient" => false,
          "frontchannelLogout" => false,
          "protocol" => "openid-connect",
          "attributes" => {
            "saml.assertion.signature" => "false",
            "access.token.lifespan" => "86400",
            "saml.multivalued.roles" => "false",
            "saml.force.post.binding" => "false",
            "saml.encrypt" => "false",
            "saml.server.signature" => "false",
            "backchannel.logout.revoke.offline.tokens" => "false",
            "saml.server.signature.keyinfo.ext" => "false",
            "exclude.session.state.from.auth.response" => "false",
            "backchannel.logout.session.required" => "true",
            "saml_force_name_id_format" => "false",
            "saml.client.signature" => "false",
            "tls.client.certificate.bound.access.tokens" => "false",
            "saml.authnstatement" => "false",
            "display.on.consent.screen" => "false",
            "saml.onetimeuse.condition" => "false"
          },
          "authenticationFlowBindingOverrides" => {},
          "fullScopeAllowed" => true,
          "nodeReRegistrationTimeout" => -1,
          "protocolMappers" => [
            {
              "id" => "2220432a-e953-422c-b176-62b65e085fe5",
              "name" => "Client Host",
              "protocol" => "openid-connect",
              "protocolMapper" => "oidc-usersessionmodel-note-mapper",
              "consentRequired" => false,
              "config" => {
                "user.session.note" => "clientHost",
                "userinfo.token.claim" => "true",
                "id.token.claim" => "true",
                "access.token.claim" => "true",
                "claim.name" => "clientHost",
                "jsonType.label" => "String"
              }
            },
            {
              "id" => "5509e428-574d-4137-b396-9108244f31ee",
              "name" => "Client IP Address",
              "protocol" => "openid-connect",
              "protocolMapper" => "oidc-usersessionmodel-note-mapper",
              "consentRequired" => false,
              "config" => {
                "user.session.note" => "clientAddress",
                "userinfo.token.claim" => "true",
                "id.token.claim" => "true",
                "access.token.claim" => "true",
                "claim.name" => "clientAddress",
                "jsonType.label" => "String"
              }
            },
            {
              "id" => "44504b93-dbce-48b8-9570-9a48d5421ae9",
              "name" => "Client ID",
              "protocol" => "openid-connect",
              "protocolMapper" => "oidc-usersessionmodel-note-mapper",
              "consentRequired" => false,
              "config" => {
                "user.session.note" => "clientId",
                "userinfo.token.claim" => "true",
                "id.token.claim" => "true",
                "access.token.claim" => "true",
                "claim.name" => "clientId",
                "jsonType.label" => "String"
              }
            }
          ],
          "defaultClientScopes" => [
            "web-origins",
            "roles",
            "profile",
            "email"
          ],
          "optionalClientScopes" => [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
          ],
          "access" => {
            "view" => true,
            "configure" => true,
            "manage" => true
          }
        }
      )
    end

    it "can convert to json" do
      expect(@client.to_json).to eq "{\"id\":\"c9104bc7-04d8-4348-b4df-8d883f9f6095\",\"name\":\"Client TEST\",\"clientId\":\"clien-test\",\"description\":\"Test to parse a client repsentation\",\"clientAuthenticatorType\":\"client-secret\",\"alwaysDisplayInConsole\":false,\"surrogateAuthRequired\":false,\"redirectUris\":[],\"webOrigins\":[],\"notBefore\":0,\"bearerOnly\":false,\"consentRequired\":false,\"standardFlowEnabled\":false,\"implicitFlowEnabled\":false,\"directAccessGrantsEnabled\":false,\"serviceAccountsEnabled\":true,\"authorizationServicesEnabled\":false,\"publicClient\":false,\"frontchannelLogout\":false,\"protocol\":\"openid-connect\",\"baseUrl\":null,\"rootUrl\":null,\"attributes\":{\"saml.assertion.signature\":\"false\",\"access.token.lifespan\":\"86400\",\"saml.multivalued.roles\":\"false\",\"saml.force.post.binding\":\"false\",\"saml.encrypt\":\"false\",\"saml.server.signature\":\"false\",\"backchannel.logout.revoke.offline.tokens\":\"false\",\"saml.server.signature.keyinfo.ext\":\"false\",\"exclude.session.state.from.auth.response\":\"false\",\"backchannel.logout.session.required\":\"true\",\"saml_force_name_id_format\":\"false\",\"saml.client.signature\":\"false\",\"tls.client.certificate.bound.access.tokens\":\"false\",\"saml.authnstatement\":\"false\",\"display.on.consent.screen\":\"false\",\"saml.onetimeuse.condition\":\"false\"},\"authenticationFlowBindingOverrides\":{},\"fullScopeAllowed\":true,\"nodeReRegistrationTimeout\":-1,\"protocolMappers\":[{\"id\":\"2220432a-e953-422c-b176-62b65e085fe5\",\"config\":{\"user.session.note\":\"clientHost\",\"userinfo.token.claim\":\"true\",\"id.token.claim\":\"true\",\"access.token.claim\":\"true\",\"claim.name\":\"clientHost\",\"jsonType.label\":\"String\"},\"name\":\"Client Host\",\"protocol\":\"openid-connect\",\"protocolMapper\":\"oidc-usersessionmodel-note-mapper\"},{\"id\":\"5509e428-574d-4137-b396-9108244f31ee\",\"config\":{\"user.session.note\":\"clientAddress\",\"userinfo.token.claim\":\"true\",\"id.token.claim\":\"true\",\"access.token.claim\":\"true\",\"claim.name\":\"clientAddress\",\"jsonType.label\":\"String\"},\"name\":\"Client IP Address\",\"protocol\":\"openid-connect\",\"protocolMapper\":\"oidc-usersessionmodel-note-mapper\"},{\"id\":\"44504b93-dbce-48b8-9570-9a48d5421ae9\",\"config\":{\"user.session.note\":\"clientId\",\"userinfo.token.claim\":\"true\",\"id.token.claim\":\"true\",\"access.token.claim\":\"true\",\"claim.name\":\"clientId\",\"jsonType.label\":\"String\"},\"name\":\"Client ID\",\"protocol\":\"openid-connect\",\"protocolMapper\":\"oidc-usersessionmodel-note-mapper\"}],\"defaultClientScopes\":[\"web-origins\",\"roles\",\"profile\",\"email\"],\"optionalClientScopes\":[\"address\",\"phone\",\"offline_access\",\"microprofile-jwt\"],\"access\":{\"view\":true,\"configure\":true,\"manage\":true}}"
    end
  end
end
