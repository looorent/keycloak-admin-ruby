module KeycloakAdmin
  class ConfigurableTokenClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def token_url
      "#{realm_url}/configurable-token"
    end

    def realm_url
      @realm_client.realm_url
    end

    def exchange_with(user_access_token, token_lifespan_in_seconds)
      response = execute_http do
        RestClient.post(token_url, {
          tokenLifespanInSeconds: token_lifespan_in_seconds
        }.to_json, {
          Authorization: "Bearer #{user_access_token}",
          content_type:  :json,
          accept:        :json
        })
      end
      TokenRepresentation.from_json(response.body)
    end
  end
end
