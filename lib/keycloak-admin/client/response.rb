module KeycloakAdmin
  # Wraps a Faraday::Response the way RestClient::Response used to: as the body string
  # itself (RestClient::Response < String), so existing call sites that do JSON.parse(response)
  # or response.to_i keep working, while .body/.headers/.status/.code/.reason_phrase stay
  # available for call sites that need response metadata.
  class Response < String
    attr_reader :status, :reason_phrase, :headers

    def initialize(faraday_response)
      super(faraday_response.body.to_s)
      @status        = faraday_response.status
      @reason_phrase = faraday_response.reason_phrase
      @headers       = symbolize_headers(faraday_response.headers)
    end

    alias_method :code, :status
    alias_method :body, :to_s

    private

    def symbolize_headers(faraday_headers)
      faraday_headers.each_with_object({}) do |(key, value), result|
        symbol_key         = key.downcase.tr("-", "_").to_sym
        result[symbol_key] = symbol_key == :set_cookie ? split_set_cookie(value) : value
      end
    end

    # Net::HTTP (used by Faraday's default adapter) joins repeated Set-Cookie header lines with
    # ", " (see Net::HTTPHeader#each_header), losing the one-header-per-cookie structure RestClient
    # exposed as an Array. Re-split on cookie boundaries rather than on every comma, since a comma
    # can also appear inside a cookie's own "Expires=Wed, 09 Jun 2027 ..." attribute.
    def split_set_cookie(value)
      value.split(/,(?=\s*[^;\s]+=)/).map(&:strip)
    end
  end
end
