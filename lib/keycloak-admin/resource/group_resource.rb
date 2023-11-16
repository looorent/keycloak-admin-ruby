module KeycloakAdmin
  class GroupResource < BaseRoleContainingResource
    def resources_name
      "groups"
    end
    
    def members(first:0, max:100)
      @realm_client.groups.members(@resource_id, first, max)
    end
  end
end
