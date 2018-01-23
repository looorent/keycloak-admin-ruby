require "http-cookie"

module KeycloakAdmin
  class ImpersonationRepresentation < Representation
    attr_accessor :set_cookie_strings,
      :set_cookies,
      :same_realm,
      :redirect

    def self.from_response(response, origin)
      body                              = JSON.parse(response.body)
      representation                    = new
      representation.set_cookie_strings = response.headers[:set_cookie]
      representation.set_cookies        = set_cookie_strings.map { |set_cookie| parse_set_cookie_string(set_cookie, origin) }
      representation.same_realm         = body["sameRealm"]
      representation.redirect           = body["redirect"]
      representation
    end

    def self.parse_set_cookie_string(set_cookie_string, origin)
      HTTP::Cookie.parse(set_cookie_string, origin).first
    end

    def cookies_to_rails_hash
      @set_cookies.map do |cookie|
        rails_cookie = {
          value:    cookie.value,
          httponly: cookie.httponly,
          expires:  cookie.expires,
          path:     cookie.path
        }
        
        rails_cookie[:domain]  = cookie.domain  if cookie.for_domain
        rails_cookie[:max_age] = cookie.max_age if cookie.max_age
        rails_cookie[:secure]  = cookie.secure  if cookie.secure
        rails_cookie
      end
    end
  end
end
