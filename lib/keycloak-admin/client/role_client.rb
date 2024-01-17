module KeycloakAdmin
  class RoleClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def list
      response = execute_http do
        RestClient::Resource.new(roles_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| RoleRepresentation.from_hash(role_as_hash) }
    end
    
    # Returns the role representation for the specified role name
    def get(name)
      # allows special characters in the name like space
      name = URI.encode_uri_component(name)
      response = execute_http do
        RestClient::Resource.new(role_name_url(name), @configuration.rest_client_options).get(headers)
      end
      RoleRepresentation.from_hash JSON.parse(response)
    end

    # Lists all groups that have the specified role name assigned
    def list_groups(name)
      # allows special characters in the name like space
      name = URI.encode_uri_component(name)
      response = execute_http do
        RestClient::Resource.new("#{role_name_url(name)}/groups", @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| GroupRepresentation.from_hash(role_as_hash) }
    end

    def save(role_representation)
      execute_http do
        RestClient::Resource.new(roles_url, @configuration.rest_client_options).post(
          create_payload(role_representation), headers
        )
      end
    end

    def roles_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/roles/#{id}"
      else
        "#{@realm_client.realm_admin_url}/roles"
      end
    end
    
    def role_name_url(name)
      "#{@realm_client.realm_admin_url}/roles/#{name}"
    end
    
  end
end
