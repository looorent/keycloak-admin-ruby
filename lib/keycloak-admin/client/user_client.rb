module KeycloakAdmin
  class UserClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def create!(username, email, password, email_verified)
      user = save(build(username, email, password, email_verified))
      search(user.email)&.first
    end

    def save(user_representation)
      execute_http do
        RestClient.post(users_url, user_representation.to_json, headers)
      end
      user_representation
    end

    def search(query)
      response = execute_http do
        RestClient.get(users_url, headers.merge({params: { search: query }}))
      end
      JSON.parse(response).map { |user_as_hash| UserRepresentation.from_hash(user_as_hash) }
    end

    def delete(user_id)
      execute_http do
        RestClient.delete(users_url(user_id), headers)
      end
      true
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

    private

    def build(username, email, password, email_verified)
      user                = UserRepresentation.new
      user.email          = email
      user.username       = username
      user.email_verified = email_verified
      user.enabled        = true
      user.add_credential(CredentialRepresentation.from_password(password))
      user
    end
  end
end
