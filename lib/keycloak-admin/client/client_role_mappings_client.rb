module KeycloakAdmin
  class ClientRoleMappingsClient < Client
    def initialize(configuration, user_resource, client_id)
      super(configuration)
      @user_resource = user_resource
      @client_id = client_id
    end

    def list_available
      response = execute_http do
        RestClient::Resource.new(list_available_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| RoleRepresentation.from_hash(role_as_hash) }
    end

    def save(role_representation_list)
      execute_http do
        RestClient::Resource.new(base_url, @configuration.rest_client_options).post(
          create_payload(role_representation_list), headers
        )
      end
    end

    def list_available_url
      "#{@user_resource.resource_url}/role-mappings/clients/#{@client_id}/available"
    end

    def base_url
      "#{@user_resource.resource_url}/role-mappings/clients/#{@client_id}"
    end
  end
end
