module KeycloakAdmin
  class GroupRepresentation < Representation
    attr_accessor :id,
      :name,
      :path

    def self.from_hash(hash)
      group      = new
      group.id   = hash["id"]
      group.name = hash["name"]
      group.path = hash["path"]
      group
    end
  end
end
