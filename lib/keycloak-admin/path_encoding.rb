require "uri"

module KeycloakAdmin
  # Percent-encoding for the identifiers interpolated into a URL path.
  #
  # Included by Client and BaseRoleContainingResource, which have no common ancestor but
  # both build URLs out of caller-supplied values.
  module PathEncoding
    private

    # Encodes '/' as %2F too, so an identifier can never open a path segment of its own.
    # Values that are already URL-safe - the UUIDs Keycloak hands out - come out unchanged,
    # so this is a no-op for the usual case.
    #
    # Without it, any identifier holding a character that is illegal in a URI (a space, most
    # obviously) made Ruby's URI parser raise URI::InvalidURIError before the request was
    # ever sent. That is reachable with values users choose themselves, identity provider
    # aliases being the clearest case.
    def encode_segment(value)
      URI.encode_uri_component(value.to_s)
    end
  end
end
