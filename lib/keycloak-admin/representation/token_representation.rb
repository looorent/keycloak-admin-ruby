
module KeycloakAdmin
  class TokenRepresentation < Representation
    attr_accessor :access_token

    def initialize(access_token)
      @access_token = access_token
    end

    def self.from_hash(hash)
      new(hash["access_token"])
    end
  end
end
