# frozen_string_literal: true
module KeycloakAdmin
  class Error < StandardError; end

  # Raised when Keycloak answers with a non-2xx status.
  #
  # Callers can rescue the precise failure (KeycloakAdmin::NotFoundError), a whole family
  # (KeycloakAdmin::ClientError for any 4xx) or every HTTP failure (KeycloakAdmin::ApiError),
  # and read #status/#body off the exception rather than parsing the message.
  class ApiError < Error
    attr_reader :status, :body, :headers

    def initialize(status, body, headers = {})
      @status  = status
      @body    = body
      @headers = headers || {}
      super("Keycloak: The request failed with response code #{status} and message: #{body}")
    end

    def self.from_response(response)
      response ||= {}
      status     = response[:status]
      error_class_for(status).new(status, response[:body], response[:headers])
    end

    def self.error_class_for(status)
      case status
      when 400      then BadRequestError
      when 401      then UnauthorizedError
      when 403      then ForbiddenError
      when 404      then NotFoundError
      when 409      then ConflictError
      when 400..499 then ClientError
      when 500..599 then ServerError
      else ApiError
      end
    end
  end

  # Any 4xx: the request itself was rejected.
  class ClientError < ApiError; end

  class BadRequestError   < ClientError; end
  class UnauthorizedError < ClientError; end
  class ForbiddenError    < ClientError; end
  class NotFoundError     < ClientError; end
  class ConflictError     < ClientError; end

  # Any 5xx: Keycloak accepted the request but failed to serve it.
  class ServerError < ApiError; end

  # Raised when a create call succeeds at the HTTP level but answers something other than
  # 201 Created, leaving no Location header to read the new resource's id from.
  class UnexpectedResponseError < Error
    attr_reader :status, :reason_phrase

    def initialize(status, reason_phrase)
      @status        = status
      @reason_phrase = reason_phrase
      super("Create method returned status #{reason_phrase} (Code: #{status}); expected status: Created (201)")
    end
  end
end
