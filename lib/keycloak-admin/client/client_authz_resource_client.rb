module KeycloakAdmin
  class ClientAuthzResourceClient < Client
    def initialize(configuration, realm_client, client_id)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
      @client_id = client_id
    end

    def list
      response = execute_http do
        RestClient::Resource.new(authz_resources_url(@client_id), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzResourceRepresentation.from_hash(role_as_hash) }
    end

    def authz_resources_url(client_id, id = nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/resource/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/resource"
      end
    end

  end
end