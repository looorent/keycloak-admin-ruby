module KeycloakAdmin
  class OrganizationDomainRepresentation < Representation
    attr_accessor :name, :verified

    def initialize(name, verified)
      @name     = name
      @verified = verified
    end

    def self.from_hash(hash)
      new(hash["name"], hash["verified"])
    end
  end
end




