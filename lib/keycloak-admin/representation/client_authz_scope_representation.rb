module KeycloakAdmin
  class ClientAuthzScopeRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :icon_uri,
                  :display_name

    def self.from_hash(hash)
      scope                                      = new
      scope.id                                   = hash["id"]
      scope.name                                 = hash["name"]
      scope.icon_uri                             = hash["iconUri"]
      scope.display_name                         = hash["displayName"]
      scope
    end
  end
end