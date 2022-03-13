module KeycloakAdmin
  class Client

    def initialize(configuration)
      @configuration = configuration
    end

    def server_url
      @configuration.server_url
    end

    def current_token
      @current_token ||= KeycloakAdmin.realm(@configuration.client_realm_name).token.get
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
    rescue RestClient::Exceptions::Timeout => e
      raise
    rescue RestClient::ExceptionWithResponse => e
      http_error(e.response)
    end

    def created_id(response)
      unless response.net_http_res.is_a? Net::HTTPCreated
        raise "Create method returned status #{response.net_http_res.message} (Code: #{response.net_http_res.code}); expected status: Created (201)"
      end
      (_head, _separator, id) = response.headers[:location].rpartition('/')
      id
    end

    def create_payload(value)
      if value.nil?
        ""
      elsif value.kind_of?(Array)
        "[#{value.map(&:to_json) * ','}]"
      else
        value.to_json
      end
    end

    private

    def http_error(response)
      raise "Keycloak: The request failed with response code #{response.code} and message: #{response.body}"
    end
  end
end
