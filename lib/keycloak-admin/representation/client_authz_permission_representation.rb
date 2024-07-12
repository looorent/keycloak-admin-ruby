# frozen_string_literal: true


## ### {"resources":["4f55e984-d1ec-405c-a25c-1387f88acd5c"],"policies":["e9e3bc49-fe11-4287-b6fc-fa8be4930ffa"],"name":"delme policy","description":"delme polidy ","decisionStrategy":"UNANIMOUS","resourceType":""}
#
module KeycloakAdmin
  class ClientAuthzPermissionRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :description,
                  :decision_strategy,
                  :resource_type,
                  :resources,
                  :policies,
                  :scopes,
                  :logic,
                  :type

    def self.from_hash(hash)
      resource                   = new
      resource.id                = hash["id"]
      resource.name              = hash["name"]
      resource.description       = hash["description"]
      resource.decision_strategy = hash["decisionStrategy"]
      resource.resource_type     = hash["resourceType"]
      resource.resources         = hash["resources"]
      resource.policies          = hash["policies"]
      resource.scopes            = hash["scopes"]
      resource.logic             = hash["logic"]
      resource.type              = hash["type"]
      resource
    end
  end
end