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

    def roles_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/roles/#{id}"
      else
        "#{@realm_client.realm_admin_url}/roles"
      end
    end
  end
end
