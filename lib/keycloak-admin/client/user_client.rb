module KeycloakAdmin
  class UserClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def create!(username, email, password, email_verified, locale)
      user = save(build(username, email, password, email_verified, locale))
      search(user.email)&.first
    end

    def save(user_representation)
      execute_http do
        RestClient::Resource.new(users_url, @configuration.rest_client_options).post(
          user_representation.to_json, headers
        )
      end
      user_representation
    end

    def update(user_id, user_representation_body)
      RestClient::Request.execute(
        @configuration.rest_client_options.merge(
          method: :put,
          url: users_url(user_id),
          payload: user_representation_body.to_json,
          headers: headers
        )
      )
    end

    def get(user_id)
      response = execute_http do
        RestClient::Resource.new(users_url(user_id), @configuration.rest_client_options).get(headers)
      end
      UserRepresentation.from_hash(JSON.parse(response))
    end

    def search(query)
      derived_headers = query ? headers.merge({params: { search: query }}) : headers
      response = execute_http do
        RestClient::Resource.new(users_url, @configuration.rest_client_options).get(derived_headers)
      end
      JSON.parse(response).map { |user_as_hash| UserRepresentation.from_hash(user_as_hash) }
    end

    def list
      search(nil)
    end

    def delete(user_id)
      execute_http do
        RestClient::Resource.new(users_url(user_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def groups(user_id)
      response = execute_http do
        RestClient::Resource.new(groups_url(user_id), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |group_as_hash| GroupRepresentation.from_hash(group_as_hash) }
    end

    def update_password(user_id, new_password)
      execute_http do
        RestClient::Request.execute(
          @configuration.rest_client_options.merge(
            method: :put,
            url: reset_password_url(user_id),
            payload: { type: 'password', value: new_password, temporary: false }.to_json,
            headers: headers
          )
        )
      end
      user_id
    end

    def impersonate(user_id)
      impersonation = get_redirect_impersonation(user_id)
      response = execute_http do
        RestClient::Request.execute(
          @configuration.rest_client_options.merge(
            method: :post,
            url: imporsonation.impersonation_url,
            payload: impersonation.body.to_json,
            headers: impersonation.headers
          )
        )
      end
      ImpersonationRepresentation.from_response(response, @configuration.server_domain)
    end

    def get_redirect_impersonation(user_id)
      ImpersonationRedirectionRepresentation.from_url(impersonation_url(user_id), headers)
    end

    def link_idp(user_id, idp_id, idp_user_id, idp_username)
      fed_id_rep                   = FederatedIdentityRepresentation.new
      fed_id_rep.user_id           = idp_user_id
      fed_id_rep.user_name         = idp_username
      fed_id_rep.identity_provider = idp_id

      execute_http do
        RestClient::Request.execute(
          @configuration.rest_client_options.merge(
            method: :post,
            url: federated_identity_url(user_id, idp_id),
            payload: fed_id_rep.to_json,
            headers: headers
          )
        )
      end
    end

    def unlink_idp(user_id, idp_id)
      execute_http do
        RestClient::Resource.new(federated_identity_url(user_id, idp_id), @configuration.rest_client_options).delete(headers)
      end
    end

    def users_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/users/#{id}"
      else
        "#{@realm_client.realm_admin_url}/users"
      end
    end

    def reset_password_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/reset-password"
    end

    def groups_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/groups"
    end

    def impersonation_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/impersonation"
    end

    def federated_identity_url(user_id, identity_provider)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      raise ArgumentError.new("identity_provider must be defined") if identity_provider.nil?
      "#{users_url(user_id)}/federated-identity/#{identity_provider}"
    end

    private

    def build(username, email, password, email_verified, locale)
      user                     = UserRepresentation.new
      user.email               = email
      user.username            = username
      user.email_verified      = email_verified
      user.enabled             = true
      user.attributes          = {}
      user.attributes[:locale] = locale if locale
      user.add_credential(CredentialRepresentation.from_password(password))
      user
    end
  end
end
