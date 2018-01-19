module KeycloakAdmin
  class Client

    def initialize(configuration)
      @configuration = configuration
    end

    def server_url
      @configuration.server_url
    end

    def token
      @token ||= KeycloakAdmin.realm(@configuration.user_realm_name).token.get
    end

    def headers
      {
        Authorization: "Bearer #{token.access_token}",
        content_type: :json,
        accept:       :json
      }
    end

    private

    def error(response)
      raise "Keycloak: The request failed with response code #{response.code} and message: #{response.body}"
    end
  end
end
