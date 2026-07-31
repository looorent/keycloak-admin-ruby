require "faraday"
require "uri"

module KeycloakAdmin
  # Thin facade over Faraday that mirrors RestClient::Resource/RestClient::Request's call
  # shape, so every client class can build/send requests without depending on Faraday's API
  # directly.
  class Resource
    MIME_TYPES = { json: "application/json" }.freeze

    def self.execute(options)
      options = options.dup
      method  = options.delete(:method)
      url     = options.delete(:url)
      payload = options.delete(:payload)
      headers = options.delete(:headers) || {}
      new(url, options).send(:request, method, payload, headers)
    end

    def self.put(url, payload, headers = {})
      new(url, {}).put(payload, headers)
    end

    def initialize(url, options = {})
      @url     = url
      @options = options || {}
    end

    def get(headers = {})
      request(:get, nil, headers)
    end

    def delete(headers = {})
      request(:delete, nil, headers)
    end

    def post(payload, headers = {})
      request(:post, payload, headers)
    end

    def put(payload, headers = {})
      request(:put, payload, headers)
    end

    private

    def request(method, payload, headers)
      headers      = headers || {}
      query        = headers[:params]
      send_headers = build_headers(headers.reject { |key, _| key == :params })
      body         = encode_payload(payload)

      # RestClient::Payload::UrlEncoded always stamped this Content-Type for Hash payloads,
      # regardless of what the caller's headers said; token retrieval relies on it and never
      # sets content_type itself.
      if payload.is_a?(Hash) && !send_headers.key?("Content-Type")
        send_headers["Content-Type"] = "application/x-www-form-urlencoded"
      end

      faraday_response = connection.public_send(method) do |req|
        req.params.update(query) if query
        send_headers.each { |name, value| req.headers[name] = value }
        req.body = body unless body.nil?
      end
      Response.new(faraday_response)
    end

    def connection
      Faraday.new(url: @url, **@options) do |f|
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end

    def encode_payload(payload)
      return nil if payload.nil?
      payload.is_a?(Hash) ? URI.encode_www_form(payload) : payload.to_s
    end

    def build_headers(headers)
      headers.each_with_object({}) do |(key, value), result|
        name         = key.is_a?(Symbol) ? humanize(key) : key.to_s
        result[name] = value.is_a?(Symbol) ? MIME_TYPES.fetch(value, value.to_s) : value
      end
    end

    def humanize(key)
      key.to_s.split("_").map { |word| word.capitalize }.join("-")
    end
  end
end
