module KeycloakAdmin
  class RealmRepresentation < Representation
    attr_accessor :id,
      :realm,
      :browser_security_headers
    # TODO: Add more attributes

    def self.from_hash(hash)
      realm       = new
      realm.id    = hash["id"]
      realm.realm = hash["realm"]
      realm.browser_security_headers = hash["browserSecurityHeaders"]
      realm
    end
  end
end
