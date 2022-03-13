module KeycloakAdmin
  class ProtocolMapperRepresentation < Representation
    attr_accessor :config,
                  :id,
                  :name,
                  :protocol,
                  :protocolMapper

    def self.from_hash(hash)
      rep                 = new
      rep.id              = hash["id"]
      rep.config          = hash["config"]
      rep.name            = hash["name"]
      rep.protocol        = hash["protocol"]
      rep.protocolMapper = hash["protocolMapper"]
      rep
    end
  end
end
