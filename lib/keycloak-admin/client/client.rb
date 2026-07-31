module KeycloakAdmin
  class Client

    def initialize(configuration)
      @configuration = configuration
    end

    def server_url
      @configuration.server_url&.sub(/\/+\z/, "")
    end

    def current_token
      @current_token ||= KeycloakAdmin.create_client(@configuration, @configuration.client_realm_name).token.get
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

    def resource(url)
      Resource.new(url, @configuration.faraday_options, @configuration.logger)
    end

    def http_error(response)
      raise "Keycloak: The request failed with response code #{response[:status]} and message: #{response[:body]}"
    end
  end
end
