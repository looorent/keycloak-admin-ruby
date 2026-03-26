module KeycloakAdmin
  class ClientScopeRepresentation < Representation
    attr_accessor :id,
                  :name,
                  :description,
                  :protocol,
                  :attributes,
                  :protocolMappers

    def self.from_hash(hash)
      rep                  = new
      rep.id               = hash["id"]
      rep.name             = hash["name"]
      rep.description      = hash["description"]
      rep.protocol         = hash["protocol"]
      rep.attributes       = hash["attributes"]
      rep.protocol_mappers = (hash["protocolMappers"] || []).map { |m| ProtocolMapperRepresentation.from_hash(m) }
      rep
    end
  end
end
