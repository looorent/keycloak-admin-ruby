require "base64"

module KeycloakAdmin
  class Configuration
    attr_accessor :server_url, :server_domain, :client_id, :client_secret, :client_realm_name, :use_service_account, :username, :password, :logger, :rest_client_options

    def body_for_token_retrieval
      if use_service_account
        body_for_service_account
      else
        body_for_username_and_password
      end
    end

    def headers_for_token_retrieval
      if use_service_account
        headers_for_service_account
      else
        headers_for_username_and_password
      end
    end

    private

    def body_for_service_account
      {
        grant_type:    "client_credentials"
      }
    end

    def body_for_username_and_password
      {
        username:      username,
        password:      password,
        grant_type:    "password",
        client_id:     client_id,
        client_secret: client_secret
      }
    end

    def headers_for_service_account
      id_and_secret = Base64::strict_encode64("#{client_id}:#{client_secret}")
      {
        Authorization: "Basic #{id_and_secret}"
      }
    end

    def headers_for_username_and_password
      {}
    end
  end
end
