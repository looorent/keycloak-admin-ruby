module KeycloakAdmin
  class ClientRoleClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def list(client_id)
      response = execute_http do
        RestClient::Resource.new(clients_url(client_id), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| RoleRepresentation.from_hash(role_as_hash) }
    end

    def clients_url(id)
      "#{@realm_client.realm_admin_url}/clients/#{id}/roles"
    end
  end
end
