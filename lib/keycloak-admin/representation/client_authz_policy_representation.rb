module KeycloakAdmin
  class ClientAuthzPolicyRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :description,
                  :type,
                  :logic,
                  :decision_strategy,
                  :config,
                  :fetch_roles,
                  :roles

    def self.from_hash(hash)
      resource                      = new
      resource.id                   = hash["id"]
      resource.name                 = hash["name"]
      resource.description          = hash["description"]
      resource.type                 = hash["type"]
      resource.logic                = hash["logic"]
      resource.decision_strategy    = hash["decisionStrategy"]
      resource.roles                = hash["roles"]
      resource.fetch_roles          = hash["fetchRoles"]
      resource.config               = ClientAuthzPolicyConfigRepresentation.from_hash((hash["config"] || {}))
      resource
    end
  end
end