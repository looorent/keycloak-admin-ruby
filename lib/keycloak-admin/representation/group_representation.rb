module KeycloakAdmin
  class GroupRepresentation < Representation
    attr_accessor :id,
      :name,
      :path,
      :attributes,
      :sub_group_count,
      :sub_groups

    def self.from_hash(hash)
      group                 = new
      group.id              = hash["id"]
      group.name            = hash["name"]
      group.path            = hash["path"]
      group.attributes      = hash.fetch("attributes", {}).map { |k, v| [k.to_sym, Array(v)] }.to_h
      group.sub_group_count = hash["subGroupCount"]
      group.sub_groups      = hash.fetch("subGroups", []).map { |sub_group_hash| self.from_hash(sub_group_hash) }
      group
    end
  end
end
