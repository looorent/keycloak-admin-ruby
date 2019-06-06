module KeycloakAdmin
  class Client

    def initialize(configuration)
      @configuration = configuration
    end

    def server_url
      @configuration.server_url
    end

    def token
      @token ||= KeycloakAdmin.realm(@configuration.client_realm_name).token.get
    end

    def headers
      {
        Authorization: "Bearer #{token.access_token}",
        content_type: :json,
        accept:       :json
      }
    end

    def execute_http
      yield
    rescue RestClient::Exceptions::Timeout => e
      raise
    rescue RestClient::ExceptionWithResponse => e
      http_error(e.response)
    end

    private

    def http_error(response)
      raise "Keycloak: The request failed with response code #{response.code} and message: #{response.body}"
    end
  end
end
