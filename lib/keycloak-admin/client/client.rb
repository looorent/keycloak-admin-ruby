# frozen_string_literal: true
require "uri"

module KeycloakAdmin
  class Client
    include PathEncoding

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
      @configuration.fetch_token_once { fetch_token }
    end

    def headers
      {
        Authorization: "Bearer #{current_token.access_token}",
        content_type: :json,
        accept:       :json
      }
    end

    def execute_http
      replayed = false
      begin
        yield
      rescue Faraday::TimeoutError
        raise
      rescue Faraday::ClientError, Faraday::ServerError => e
        if !replayed && e.response && e.response[:status] == 401 && !@configuration.cached_token.nil?
          @configuration.clear_cached_token!
          replayed = true
          retry
        end
        raise ApiError.from_response(e.response)
      end
    end

    def created_id(response)
      unless response.status == 201
        raise UnexpectedResponseError.new(response.status, response.reason_phrase)
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

    def build_query(parameters)
      parameters.flat_map do |name, value|
        encoded_name = URI.encode_uri_component(name.to_s)
        values       = value.is_a?(Array) ? value : [value]
        values.map { |single_value| "#{encoded_name}=#{URI.encode_uri_component(single_value.to_s)}" }
      end.join("&")
    end

    def fetch_token
      KeycloakAdmin.create_client(@configuration, @configuration.client_realm_name).token.get
    end

    def resource(url)
      Resource.new(url, @configuration.faraday_options, @configuration.logger)
    end
  end
end
