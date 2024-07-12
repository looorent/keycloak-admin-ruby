module KeycloakAdmin
  class ClientAuthzPolicyConfigRepresentation < Representation
    attr_accessor :roles,
                  :code

    def self.from_hash(hash)
      resource                      = new
      resource.code                 = hash["code"]
      resource.roles               = JSON.parse(hash["roles"] || '[]').map do |str|
        RoleRepresentation.from_hash(str)
      end
      resource
    end
  end
end