module KeycloakAdmin
  class ImpersonationRedirectionRepresentation < Representation
    attr_reader :headers, :impersonation_url, :http_method, :body

    def self.from_url(url, headers)
      @http_method       = :post
      @body              = {}
      @impersonation_url = url
      @headers           = headers
    end
  end
end
