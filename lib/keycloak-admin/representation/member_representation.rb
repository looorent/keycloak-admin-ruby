module KeycloakAdmin
  class MemberRepresentation < UserRepresentation
    attr_accessor :membership_type

    def self.from_hash(hash)
      member                 = super(hash)
      member.membership_type = hash["membershipType"]
      member
    end
  end
end