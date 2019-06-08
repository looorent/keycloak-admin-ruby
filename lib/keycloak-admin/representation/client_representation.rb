module KeycloakAdmin
  class ClientRepresentation < Representation
    attr_accessor :id,
      :name,
      :client_id
    # TODO: Add more attributes

    def self.from_hash(hash)
      client           = new
      client.id        = hash["id"]
      client.name      = hash["name"]
      client.client_id = hash["clientId"]
      client
    end
  end
end
