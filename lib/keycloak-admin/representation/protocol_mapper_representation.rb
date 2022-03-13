module KeycloakAdmin
  class ProtocolMapperRepresentation < Representation
    attr_accessor :config,
                  :id,
                  :name,
                  :protocol,
                  :protocol_mapper

    def self.from_hash(hash)
      rep                 = new
      rep.id              = hash["id"]
      rep.config          = hash["config"]
      rep.name            = hash["name"]
      rep.protocol        = hash["protocol"]
      rep.protocol_mapper = hash["protocolMapper"]
      rep
    end
  end
end
