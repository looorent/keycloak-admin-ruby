module KeycloakAdmin
  class BaseRoleContainingResource
    attr_reader :resource_id

    def initialize(configuration, realm_client, resource_id)
      @configuration = configuration
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
      @resource_id = resource_id
    end

    def resources_name
      raise NotImplementedError.new("must override in subclass")
    end

    def resource_url
      "#{@realm_client.realm_admin_url}/#{resources_name}/#{@resource_id}"
    end

    def client_role_mappings(client_id)
      ClientRoleMappingsClient.new(@configuration, self, client_id)
    end

    def role_mapper
      RoleMapperClient.new(@configuration, self)
    end
  end
end
