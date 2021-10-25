module KeycloackAdminError
  class HttpError < ::StandardError
    def initialize(response)
      msg = "Keycloak: The request failed with response code #{response.code} and message: #{response.body}"
      super(msg)
    end
  end

  class TimedOut < HttpError; end

  class Unauthorized < HttpError; end

  class NotFound < HttpError; end

  class RequestFailed < HttpError; end

  class ServiceUnavailable < HttpError; end

  class BadGateway < HttpError; end

  class BadFormatRequest < HttpError; end
end
