module KeycloakAdmin
  class UserResource
    def initialize(configuration, realm_client, id)
      @configuration = configuration
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
      @id = id
    end

    def resource_url
      "#{@realm_client.realm_admin_url}/users/#{@id}"
    end

    def client_role_mappings(client_id)
      ClientRoleMappingsClient.new(@configuration, self, client_id)
    end

    def role_mapper
      RoleMapperClient.new(@configuration, self)
    end
  end
end
