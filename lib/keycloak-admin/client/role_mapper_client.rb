module KeycloakAdmin
  class RoleMapperClient < Client
    def initialize(configuration, user_resource)
      super(configuration)
      @user_resource = user_resource
    end

    def list
      response = execute_http do
        resource(realm_level_url).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| RoleRepresentation.from_hash(role_as_hash) }
    end

    def save_realm_level(role_representation_list)
      execute_http do
        resource(realm_level_url).post(
          create_payload(role_representation_list), headers
        )
      end
    end

    def remove_realm_level(role_representation_list)
      execute_http do
        Resource.execute(
          @configuration.faraday_options.merge(
            method: :delete,
            url: realm_level_url,
            payload: create_payload(role_representation_list),
            headers: headers
          )
        )
      end
    end

    def remove_all_realm_roles
      execute_http do
        resource(realm_level_url).delete(headers)
      end
      true
    end

    def realm_level_url
      "#{@user_resource.resource_url}/role-mappings/realm"
    end
  end
end
