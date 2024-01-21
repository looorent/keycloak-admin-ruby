module KeycloakAdmin
  class RoleRepresentation < Representation
    attr_accessor :id,
      :name,
      :composite,
      :client_role,
      :container_id,

    def self.from_hash(hash)
      role             = new
      role.id          = hash["id"]
      role.name        = hash["name"]
      role.composite   = hash["composite"]
      role.client_role = hash["clientRole"]
      role.container_id = hash["containerId"]
      role
    end
  end
end
