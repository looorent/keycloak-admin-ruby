module KeycloakAdmin
  class IdentityProviderRepresentation < Representation
    attr_accessor :alias,
                  :display_name,
                  :internal_id,
                  :provider_id,
                  :enabled,
                  :update_profile_first_login_mode,
                  :trust_email,
                  :store_token,
                  :add_read_token_role_on_create,
                  :authenticate_by_default,
                  :link_only,
                  :organization_id,
                  :first_broker_login_flow_alias,
                  :config

    def self.from_hash(hash)
      if hash.nil?
        nil
      else
        new(
          hash["alias"],
          hash["displayName"],
          hash["internalId"],
          hash["providerId"],
          hash["enabled"],
          hash["updateProfileFirstLoginMode"],
          hash["trustEmail"],
          hash["storeToken"],
          hash["addReadTokenRoleOnCreate"],
          hash["authenticateByDefault"],
          hash["linkOnly"],
          hash["organizationId"],
          hash["firstBrokerLoginFlowAlias"],
          hash["config"]
        )
      end
    end

    def initialize(alias_name,
                   display_name,
                   internal_id,
                   provider_id,
                   enabled,
                   update_profile_first_login_mode,
                   trust_email,
                   store_token,
                   add_read_token_role_on_create,
                   authenticate_by_default,
                   link_only,
                   organization_id,
                   first_broker_login_flow_alias,
                   config)
      @alias                           = alias_name
      @display_name                    = display_name
      @internal_id                     = internal_id
      @provider_id                     = provider_id
      @enabled                         = enabled
      @update_profile_first_login_mode = update_profile_first_login_mode
      @trust_email                     = trust_email
      @store_token                     = store_token
      @add_read_token_role_on_create   = add_read_token_role_on_create
      @authenticate_by_default         = authenticate_by_default
      @link_only                       = link_only
      @organization_id                 = organization_id
      @first_broker_login_flow_alias   = first_broker_login_flow_alias
      @config                          = config || {}
    end
  end
end
