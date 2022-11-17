require "rest-client"

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

    def revoke_token_url(user_id)
      "#{realm_url}/users/#{ user_id}/logout"
    end

    def realm_url
      @realm_client.realm_url
    end

    def get
      response = execute_http do
        RestClient::Resource.new(token_url, @configuration.rest_client_options).post(
          @configuration.body_for_token_retrieval,
          @configuration.headers_for_token_retrieval
        )
      end
      TokenRepresentation.from_json(response.body)
    end

    def revoke(user_id) 
      response = execute_http do
        RestClient::Resource.new(revoke_token_url(user_id), @configuration.rest_client_options).post(
          @configuration.body_for_token_retrieval,
          @configuration.headers_for_token_retrieval
        )
      end
      TokenRepresentation.from_json(response.body)
    end
  end
end
