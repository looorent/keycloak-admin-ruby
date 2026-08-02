module KeycloakAdmin
  class ClientRoleMappingsClient < Client
    def initialize(configuration, user_resource, client_id)
      super(configuration)
      @user_resource = user_resource
      @client_id = client_id
    end

    def list_available
      response = execute_http do
        resource(list_available_url).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| RoleRepresentation.from_hash(role_as_hash) }
    end

    def save(role_representation_list)
      execute_http do
        resource(base_url).post(
          create_payload(role_representation_list), headers
        )
      end
    end

    def list_available_url
      "#{@user_resource.resource_url}/role-mappings/clients/#{encode_segment(@client_id)}/available"
    end

    def base_url
      "#{@user_resource.resource_url}/role-mappings/clients/#{encode_segment(@client_id)}"
    end
  end
end
