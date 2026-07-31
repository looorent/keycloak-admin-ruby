module KeycloakAdmin
  class Client

    def initialize(configuration)
      @configuration = configuration
    end

    def server_url
      @configuration.server_url&.sub(/\/+\z/, "")
    end

    # Cached on @configuration, not on this instance, since a new Client subclass is
    # created for nearly every call (e.g. KeycloakAdmin.realm(x).users creates a fresh
    # UserClient) - caching here alone would fetch a new token on almost every request.
    def current_token
      @configuration.cached_token || @configuration.cache_token(fetch_token)
    end

    def headers
      {
        Authorization: "Bearer #{current_token.access_token}",
        content_type: :json,
        accept:       :json
      }
    end

    def execute_http
      yield
    rescue Faraday::TimeoutError
      raise
    rescue Faraday::ClientError, Faraday::ServerError => e
      http_error(e.response)
    end

    def created_id(response)
      unless response.status == 201
        raise "Create method returned status #{response.reason_phrase} (Code: #{response.status}); expected status: Created (201)"
      end
      (_head, _separator, id) = response.headers[:location].rpartition("/")
      id
    end

    def create_payload(value)
      if value.nil?
        ""
      elsif value.kind_of?(Array)
        "[#{value.map(&:to_json) * ","}]"
      else
        value.to_json
      end
    end

    private

    def fetch_token
      KeycloakAdmin.create_client(@configuration, @configuration.client_realm_name).token.get
    end

    def resource(url)
      Resource.new(url, @configuration.faraday_options, @configuration.logger)
    end

    def http_error(response)
      raise "Keycloak: The request failed with response code #{response[:status]} and message: #{response[:body]}"
    end
  end
end
