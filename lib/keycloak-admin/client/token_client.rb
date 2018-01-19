module KeycloakAdmin
  class TokenClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def token_url
      "#{realm_url}/protocol/openid-connect/token"
    end

    def realm_url
      @realm_client.realm_url
    end

    def get
      response = RestClient.post(token_url,
        username: @configuration.username,
        password: @configuration.password,
        grant_type: "password",
        client_id: @configuration.client_id
      )
      if response.code == 200
        TokenRepresentation.from_json(response.body)
      else
        error(response)
      end
    end
  end
end
