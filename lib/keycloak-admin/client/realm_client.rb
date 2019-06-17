module KeycloakAdmin
  class RealmClient < Client
    def initialize(configuration, realm_name=nil)
      super(configuration)
      @realm_name = realm_name
    end

    def list
      response = execute_http do
        RestClient::Resource.new(realm_list_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |realm_as_hash| RealmRepresentation.from_hash(realm_as_hash) }
    end

    def delete
      execute_http do
        RestClient::Resource.new(realm_admin_url, @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def save(realm_representation)
      execute_http do
        RestClient::Resource.new(realm_list_url, @configuration.rest_client_options).post(
          realm_representation.to_json, headers
        )
      end
    end

    def update(realm_representation_body)
      execute_http do
        RestClient::Resource.new(realm_admin_url, @configuration.rest_client_options).put(
          realm_representation_body.to_json, headers
        )
      end
    end

    def realm_url
      if @realm_name
        "#{server_url}/realms/#{@realm_name}"
      else
        "#{server_url}/realms"
      end
    end

    def realm_admin_url
      if @realm_name
        "#{server_url}/admin/realms/#{@realm_name}"
      else
        "#{server_url}/admin/realms"
      end
    end

    def realm_list_url
      "#{server_url}/admin/realms"
    end

    def token
      TokenClient.new(@configuration, self)
    end

    def configurable_token
      ConfigurableTokenClient.new(@configuration, self)
    end

    def clients
      ClientClient.new(@configuration, self)
    end

    def groups
      GroupClient.new(@configuration, self)
    end

    def group(group_id)
      GroupResource.new(@configuration, self, group_id)
    end

    def roles
      RoleClient.new(@configuration, self)
    end

    def users
      UserClient.new(@configuration, self)
    end

    def user(user_id)
      UserResource.new(@configuration, self, user_id)
    end

    def name_defined?
      !@realm_name.nil?
    end
  end
end
