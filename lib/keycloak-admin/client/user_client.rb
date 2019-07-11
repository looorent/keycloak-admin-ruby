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
      RestClient.put(users_url(user_id), user_representation_body.to_json, headers)
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
        RestClient.put(reset_password_url(user_id), {
          type: "password",
          value: new_password,
          temporary: false
        }.to_json, headers)
      end
      user_id
    end

    def impersonate(user_id)
      impersonation = get_redirect_impersonation(user_id)
      response = execute_http do
        RestClient.post(impersonation.impersonation_url, impersonation.body.to_json, impersonation.headers)
      end
      ImpersonationRepresentation.from_response(response, @configuration.server_domain)
    end

    def get_redirect_impersonation(user_id)
      ImpersonationRedirectionRepresentation.from_url(impersonation_url(user_id), headers)
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
