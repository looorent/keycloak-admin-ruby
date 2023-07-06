module KeycloakAdmin
  class SessionRepresentation < Representation
    attr_accessor :id,
      :username,
      :user_id,
      :ip_address,
      :start,
      :last_access,
      :remember_me,

    def self.from_hash(hash)
      rep                   = new
      rep.id                = hash["id"]
      rep.username          = hash["username"]
      rep.user_id           = hash["userId"]
      rep.ip_address        = hash["ipAddress"]
      rep.start             = hash["start"]
      rep.last_access       = hash["lastAccess"]
      rep.remember_me       = hash["rememberMe"]
      rep
    end
  end
end