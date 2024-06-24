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

    def create!(name, type, uris, owner_managed_access, display_name, scopes, attributes = {})
      save(build(name, type, uris, owner_managed_access, display_name, scopes, attributes))
    end

    def save(client_authz_resource_representation)
      response = execute_http do
        RestClient::Resource.new(authz_resources_url(@client_id), @configuration.rest_client_options).post(client_authz_resource_representation.to_json, headers)
      end
      ClientAuthzResourceRepresentation.from_hash(JSON.parse(response))
    end

    def authz_resources_url(client_id, id = nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/resource/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/resource"
      end
    end

    private

    def build(name, type, uris, owner_managed_access, display_name, scopes, attributes={} )
      resource                      = ClientAuthzResourceRepresentation.new
      resource.name                 = name
      resource.type                 = type
      resource.uris                 = uris
      resource.owner_managed_access = owner_managed_access
      resource.display_name         = display_name
      resource.scopes               = scopes
      resource.attributes           = attributes || {}
      resource
    end

  end
end