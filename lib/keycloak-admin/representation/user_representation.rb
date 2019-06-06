module KeycloakAdmin
  class UserRepresentation < Representation
    attr_accessor :id,
      :created_timestamp,
      :attributes,
      :origin,
      :username,
      :email,
      :enabled,
      :email_verified,
      :first_name,
      :last_name,
      :credentials

    def self.from_hash(hash)
      user                   = new
      user.id                = hash["id"]
      user.created_timestamp = hash["createdTimestamp"]
      user.origin            = hash["origin"]
      user.username          = hash["username"]
      user.email             = hash["email"]
      user.enabled           = hash["enabled"]
      user.email_verified    = hash["emailVerified"]
      user.first_name        = hash["firstName"]
      user.last_name         = hash["lastName"]
      user.attributes        = hash["attributes"]
      user.credentials       = hash["credentials"]&.map{ |hash| CredentialRepresentation.from_hash(hash) } || []
      user
    end

    def add_credential(credential_representation)
      @credentials ||= []
      @credentials.push(credential_representation)
    end
  end
end
