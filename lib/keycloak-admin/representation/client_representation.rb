module KeycloakAdmin
  class ClientRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :client_id,
                  :description,
                  :client_authenticator_type,
                  :always_display_in_console,
                  :surrogate_auth_required,
                  :redirect_uris,
                  :web_origins,
                  :not_before,
                  :bearer_only,
                  :consent_required,
                  :standard_flow_enabled,
                  :implicit_flow_enabled,
                  :direct_access_grants_enabled,
                  :service_accounts_enabled,
                  :authorization_services_enabled,
                  :public_client,
                  :frontchannel_logout,
                  :protocol,
                  :base_url,
                  :root_url,
                  :attributes,
                  :authentication_flow_binding_overrides,
                  :full_scope_allowed,
                  :node_re_registration_timeout,
                  :attributes,
                  :protocol_mappers,
                  :default_client_scopes,
                  :optional_client_scopes,
                  :access

    def self.from_hash(hash)
      client                                       = new
      client.id                                    = hash["id"]
      client.name                                  = hash["name"]
      client.client_id                             = hash["clientId"]
      client.description                           = hash["description"]
      client.client_authenticator_type             = hash["clientAuthenticatorType"]
      client.always_display_in_console             = hash["alwaysDisplayInConsole"] || false
      client.surrogate_auth_required               = hash["surrogateAuthRequired"] || false
      client.redirect_uris                         = hash["redirectUris"] || false
      client.web_origins                           = hash["webOrigins"] || false
      client.not_before                            = hash["notBefore"] || false
      client.bearer_only                           = hash["bearerOnly"] || false
      client.consent_required                      = hash["consentRequired"] || false
      client.standard_flow_enabled                 = hash["standardFlowEnabled"] || false
      client.implicit_flow_enabled                 = hash["implicitFlowEnabled"] || false
      client.direct_access_grants_enabled          = hash["directAccessGrantsEnabled"] || false
      client.service_accounts_enabled              = hash["serviceAccountsEnabled"] || false
      client.authorization_services_enabled        = hash["authorizationServicesEnabled"] || false
      client.public_client                         = hash["publicClient"] || false
      client.frontchannel_logout                   = hash["frontchannelLogout"] || false
      client.protocol                              = hash["protocol"]
      client.base_url                              = hash["baseUrl"]
      client.root_url                              = hash["rootUrl"]
      client.attributes                            = hash["attributes"] || {}
      client.authentication_flow_binding_overrides = hash["authenticationFlowBindingOverrides"] || {}
      client.full_scope_allowed                    = hash["fullScopeAllowed"] || false
      client.node_re_registration_timeout          = hash["nodeReRegistrationTimeout"] || -1
      client.attributes                            = hash["attributes"]
      client.protocol_mappers                      = (hash["protocolMappers"] || []).map { |protocol_mapper_hash| ProtocolMapperRepresentation.from_hash(protocol_mapper_hash) }
      client.default_client_scopes                 = hash["defaultClientScopes"] || []
      client.optional_client_scopes                = hash["optionalClientScopes"] || []
      client.access                                = hash["access"] || {}
      client
    end
  end
end
