require 'rest-client'

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
      response = execute_http do
        RestClient.post(token_url, @configuration.body_for_token_retrieval, @configuration.headers_for_token_retrieval)
      end
      TokenRepresentation.from_json(response.body)
    end
  end
end
