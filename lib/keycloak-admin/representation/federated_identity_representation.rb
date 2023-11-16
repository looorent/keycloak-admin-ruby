module KeycloakAdmin
  class FederatedIdentityRepresentation < Representation
    attr_accessor :identity_provider,
      :user_id,
      :user_name

    def self.from_hash(hash)
      rep                   = new
      rep.identity_provider = hash["identityProvider"]
      rep.user_id           = hash["userId"]
      rep.user_name         = hash["userName"]
      rep
    end
  end
end
