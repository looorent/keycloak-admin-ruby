module KeycloakAdmin

  class ClientAuthzResourceRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :type,
                  :icon_uri,
                  :uris,
                  :owner_managed_access,
                  :display_name,
                  :attributes,
                  :scopes

    def self.from_hash(hash)
      resource                      = new
      resource.id                   = hash["_id"]
      resource.type                 = hash["type"]
      resource.name                 = hash["name"]
      resource.owner_managed_access = hash["ownerManagedAccess"]
      resource.icon_uri             = hash["iconUri"]
      resource.uris                 = hash["uris"]
      resource.display_name         = hash["displayName"]
      resource.attributes           = hash.fetch("attributes", {}).map { |k, v| [k.to_sym, Array(v)] }.to_h
      resource.scopes               = (hash["scopes"] || []).map { |scope_hash| ClientAuthzScopeRepresentation.from_hash(scope_hash) }

      resource
    end
  end
end