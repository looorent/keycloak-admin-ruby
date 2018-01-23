module KeycloakAdmin
  class ImpersonationRedirectionRepresentation < Representation
    attr_reader :headers, :impersonation_url, :http_method, :body

    def initialize(http_method, body, impersonation_url, headers)
      @http_method       = http_method
      @body              = body
      @impersonation_url = impersonation_url
      @headers           = headers
    end

    def self.from_url(url, headers)
      new(:post, {}, url, headers)
    end
  end
end
