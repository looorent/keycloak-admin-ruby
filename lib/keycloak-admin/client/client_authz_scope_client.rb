module KeycloakAdmin
  class ClientAuthzScopeClient < Client
    def initialize(configuration, realm_client, client_id)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
      @client_id = client_id
    end

    def list
      response = execute_http do
        RestClient::Resource.new(authz_scopes_url(@client_id), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzScopeRepresentation.from_hash(role_as_hash) }
    end

    def authz_scopes_url(id)
      "#{@realm_client.realm_admin_url}/clients/#{id}/authz/resource-server/scope"
    end
  end
end