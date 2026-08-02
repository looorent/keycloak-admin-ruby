# frozen_string_literal: true
module KeycloakAdmin
  class UserClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    # Reads the id of the new user off the Location header rather than searching for it
    # afterwards: Keycloak's `search` parameter matches a substring of the username, email,
    # first name or last name, so an existing user merely containing this email was returned
    # instead of the one just created.
    def create!(username, email, password, email_verified, locale, attributes={})
      response = post_user(build(username, email, password, email_verified, locale, attributes))
      get(created_id(response))
    end

    def save(user_representation)
      post_user(user_representation)
      user_representation
    end

    # pay attention that, since Keycloak 24.0.4, partial updates of attributes are not authorized anymore
    def update(user_id, user_representation_body)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      execute_http do
        Resource.execute(
          connection_options.merge(
            method: :put,
            url: users_url(user_id),
            payload: create_payload(user_representation_body),
            headers: headers,
            logger: @configuration.logger
          )
        )
      end
    end

    def add_group(user_id, group_id)
      execute_http do
        Resource.execute(
          connection_options.merge(
            method: :put,
            url: "#{users_url(user_id)}/groups/#{encode_segment(group_id)}",
            payload: create_payload({}),
            headers: headers,
            logger: @configuration.logger
          )
        )
      end
    end

    def remove_group(user_id, group_id)
      execute_http do
        Resource.execute(
          connection_options.merge(
            method: :delete,
            url: "#{users_url(user_id)}/groups/#{encode_segment(group_id)}",
            headers: headers,
            logger: @configuration.logger
          )
        )
      end
    end

    def add_client_roles_on_user(user_id, client_id, role_representations)
      execute_http do
        resource(user_client_role_mappings_url(user_id, client_id)).post(
          create_payload(role_representations), headers
        )
      end
    end

    def get(user_id)
      response = execute_http do
        resource(users_url(user_id)).get(headers)
      end
      UserRepresentation.from_hash(JSON.parse(response))
    end

    ##
    # Query can be a string or a hash.
    # * String: It's used as search query
    # * Hash: Used for complex search queries.
    #   For its documentation see: https://www.keycloak.org/docs-api/11.0/rest-api/index.html#_users_resource
    ##
    def search(query)
      derived_headers = case query
                        when String
                          headers.merge({params: { search: query }})
                        when Hash
                          headers.merge({params: query })
                        else
                          headers
                        end

      response = execute_http do
        resource(users_url).get(derived_headers)
      end
      JSON.parse(response).map { |user_as_hash| UserRepresentation.from_hash(user_as_hash) }
    end

    def list
      search(nil)
    end

    def delete(user_id)
      execute_http do
        resource(users_url(user_id)).delete(headers)
      end
      true
    end

    def groups(user_id)
      response = execute_http do
        resource(groups_url(user_id)).get(headers)
      end
      JSON.parse(response).map { |group_as_hash| GroupRepresentation.from_hash(group_as_hash) }
    end

    def update_password(user_id, new_password)
      execute_http do
        Resource.execute(
          connection_options.merge(
            method: :put,
            url: reset_password_url(user_id),
            payload: { type: "password", value: new_password, temporary: false }.to_json,
            headers: headers,
            logger: @configuration.logger
          )
        )
      end
      user_id
    end

    def credentials(user_id)
      response = execute_http do
        resource(credentials_url(user_id)).get(headers)
      end
      JSON.parse(response).map { |group_as_hash| CredentialRepresentation.from_hash(group_as_hash) }
    end

    def forgot_password(user_id, lifespan=nil)
      execute_actions_email(user_id, ["UPDATE_PASSWORD"], lifespan)
    end

    def execute_actions_email(user_id, actions=[], lifespan=nil, redirect_uri=nil, client_id=nil)
      raise ArgumentError.new("client_id must be defined") if client_id.nil? && !redirect_uri.nil?
      execute_http do
        query = {}
        query[:client_id]    = client_id     unless client_id.nil?
        query[:redirect_uri] = redirect_uri  unless redirect_uri.nil?
        query[:lifespan]     = lifespan.to_i unless lifespan.nil?

        url = execute_actions_email_url(user_id)
        url = "#{url}?#{build_query(query)}" unless query.empty?
        resource(url).put(create_payload(actions), headers)
      end
      user_id
    end

    def impersonate(user_id)
      response = execute_http do
        impersonation = get_redirect_impersonation(user_id)
        Resource.execute(
          connection_options.merge(
            method: :post,
            url: impersonation.impersonation_url,
            payload: impersonation.body.to_json,
            headers: impersonation.headers,
            logger: @configuration.logger
          )
        )
      end
      ImpersonationRepresentation.from_response(response, @configuration.server_domain)
    end

    def sessions(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?

      response = execute_http do
        resource("#{users_url(user_id)}/sessions").get(headers)
      end
      JSON.parse(response).map { |session_as_hash| SessionRepresentation.from_hash(session_as_hash) }
    end

    def logout(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?

      execute_http do
        Resource.execute(
          connection_options.merge(
            method: :post,
            url: logout_url(user_id),
            headers: headers,
            logger: @configuration.logger
          )
        )
      end
      true
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
        Resource.execute(
          connection_options.merge(
            method: :post,
            url: federated_identity_url(user_id, idp_id),
            payload: fed_id_rep.to_json,
            headers: headers,
            logger: @configuration.logger
          )
        )
      end
    end

    def unlink_idp(user_id, idp_id)
      execute_http do
        resource(federated_identity_url(user_id, idp_id)).delete(headers)
      end
    end

    def users_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/users/#{encode_segment(id)}"
      else
        "#{@realm_client.realm_admin_url}/users"
      end
    end

    def user_client_role_mappings_url(user_id, client_id)
      "#{users_url(user_id)}/role-mappings/clients/#{encode_segment(client_id)}"
    end

    def reset_password_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/reset-password"
    end

    def execute_actions_email_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/execute-actions-email"
    end

    def groups_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/groups"
    end

    def credentials_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/credentials"
    end

    def impersonation_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      "#{users_url(user_id)}/impersonation"
    end

    def federated_identity_url(user_id, identity_provider)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      raise ArgumentError.new("identity_provider must be defined") if identity_provider.nil?
      "#{users_url(user_id)}/federated-identity/#{encode_segment(identity_provider)}"
    end

    def logout_url(user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?

      "#{users_url(user_id)}/logout"
    end

    private

    def post_user(user_representation)
      execute_http do
        resource(users_url).post(
          create_payload(user_representation), headers
        )
      end
    end

    def build(username, email, password, email_verified, locale, attributes={})
      user                     = UserRepresentation.new
      user.email               = email
      user.username            = username
      user.email_verified      = email_verified
      user.enabled             = true
      user.attributes          = (attributes || {}).dup
      user.attributes[:locale] = locale if locale
      user.add_credential(CredentialRepresentation.from_password(password)) if !password.nil?
      user
    end
  end
end
