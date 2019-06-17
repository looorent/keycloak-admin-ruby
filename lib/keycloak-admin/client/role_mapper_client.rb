module KeycloakAdmin
  class RoleMapperClient < Client
    def initialize(configuration, user_resource)
      super(configuration)
      @user_resource = user_resource
    end

    def save_realm_level(role_representation_list)
      execute_http do
        RestClient::Resource.new(realm_level_url, @configuration.rest_client_options).post(
          role_representation_list.to_json, headers
        )
      end
    end

    def realm_level_url
      "#{@user_resource.resource_url}/role-mappings/realm"
    end
  end
end
