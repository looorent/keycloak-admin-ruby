module KeycloakAdmin
  class RoleMapperClient < Client
    def initialize(configuration, user_resource)
      super(configuration)
      @user_resource = user_resource
    end

    def save_realm_level(role_representation_list)
      execute_http do
        RestClient::Resource.new(realm_level_url, @configuration.rest_client_options).post(
          create_payload(role_representation_list), headers
        )
      end
    end

    def realm_level_url
      "#{@user_resource.resource_url}/role-mappings/realm"
    end
  end
end
