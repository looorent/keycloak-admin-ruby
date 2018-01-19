
module KeycloakAdmin
  class TokenRepresentation < Representation
    attr_accessor :access_token,
      :token_type,
      :expires_in,
      :refresh_token,
      :refresh_expires_in,
      :id_token,
      :not_before_policy,
      :session_state

    def initialize(access_token, token_type, expires_in, refresh_token, refresh_expires_in, id_token, not_before_policy, session_state)
      @access_token       = access_token
      @token_type         = token_type
      @expires_in         = expires_in
      @refresh_token      = refresh_token
      @refresh_expires_in = refresh_expires_in
      @id_token           = id_token
      @not_before_policy  = not_before_policy
      @session_state      = session_state
    end

    def self.from_hash(hash)
      new(
        hash["access_token"],
        hash["token_type"],
        hash["expires_in"],
        hash["refresh_token"],
        hash["refresh_expires_in"],
        hash["id_token"],
        hash["not-before-policy"],
        hash["session_state"],
        )
    end
  end
end


