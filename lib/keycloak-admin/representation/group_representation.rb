module KeycloakAdmin
  class GroupRepresentation < Representation
    attr_accessor :id,
      :name,
      :path,
      :sub_groups

    def self.from_hash(hash)
      group            = new
      group.id         = hash["id"]
      group.name       = hash["name"]
      group.path       = hash["path"]
      group.sub_groups = hash.fetch("subGroups", []).map { |sub_group_hash| self.from_hash(sub_group_hash) }
      group
    end
  end
end
