module KeycloakAdmin
  class ClientAuthzPolicyRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :description,
                  :type,
                  :logic,
                  :decision_strategy,
                  :config

    def self.from_hash(hash)
      resource                      = new
      resource.id                   = hash["id"]
      resource.name                 = hash["name"]
      resource.description          = hash["description"]
      resource.type                 = hash["type"]
      resource.logic                = hash["logic"]
      resource.decision_strategy    = hash["decisionStrategy"]
      resource.config               = ClientAuthzPolicyConfigRepresentation.from_hash((hash["config"] || {}))
      resource
    end
  end
end