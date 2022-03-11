module KeycloakAdmin
  class IdentityProviderMapperRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :identity_provider_alias,
                  :identity_provider_mapper,
                  :config

    def self.from_hash(hash)
      client                           = new
      client.id                        = hash["id"]
      client.name                      = hash["name"]
      client.identity_provider_alias   = hash["identityProviderAlias"]
      client.identity_provider_mapper  = hash["identityProviderMapper"]
      client.config                    = hash["config"]
      client
    end
  end
end
