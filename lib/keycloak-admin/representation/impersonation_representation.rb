module KeycloakAdmin
  class ImpersonationRepresentation < Representation
    attr_accessor :cookies, :same_realm, :redirect

    def self.from_response(response)
      body                      = JSON.parse(response.body)
      representation            = new
      representation.cookies    = response.headers[:set_cookie]
      representation.same_realm = body["sameRealm"]
      representation.redirect   = body["redirect"]
      representation
    end
  end
end
