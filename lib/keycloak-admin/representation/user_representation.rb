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
      :totp,
      :credentials,
      :federated_identities,
      :required_actions

    def self.from_hash(hash)
      user                      = new
      user.id                   = hash["id"]
      user.created_timestamp    = hash["createdTimestamp"]
      user.origin               = hash["origin"]
      user.username             = hash["username"]
      user.email                = hash["email"]
      user.enabled              = hash["enabled"]
      user.email_verified       = hash["emailVerified"]
      user.first_name           = hash["firstName"]
      user.last_name            = hash["lastName"]
      user.attributes           = hash["attributes"]
      user.required_actions     = hash["requiredActions"] || []
      user.totp                 = hash["totp"] || false
      user.credentials          = hash["credentials"]&.map{ |hash| CredentialRepresentation.from_hash(hash) } || []
      user.federated_identities = hash["federatedIdentities"]&.map { |hash| FederatedIdentityRepresentation.from_hash(hash) } || []
      user
    end

    def add_credential(credential_representation)
      @credentials ||= []
      @credentials.push(credential_representation)
    end

    def add_federated_identity(federated_identity_representation)
      @federated_identities ||= []
      @federated_identities.push(federated_identity_representation)
    end
  end
end
