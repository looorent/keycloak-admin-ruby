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

    def get(resource_id)
      response = execute_http do
        RestClient::Resource.new(authz_resources_url(@client_id, resource_id), @configuration.rest_client_options).get(headers)
      end
      ClientAuthzResourceRepresentation.from_hash(JSON.parse(response))
    end

    def update(resource_id, client_authz_resource_representation)
      raise "scope[:name] is mandatory and the only necessary attribute to add scope to resource" if client_authz_resource_representation[:scopes] && client_authz_resource_representation[:scopes].any?{|a| !a[:name]}

      existing_resource = get(resource_id)
      new_resource = build(
        client_authz_resource_representation[:name] || existing_resource.name,
        client_authz_resource_representation[:type] || existing_resource.type,
        (client_authz_resource_representation[:uris] || [] ) + existing_resource.uris,
        client_authz_resource_representation[:owner_managed_access] || existing_resource.owner_managed_access,
        client_authz_resource_representation[:display_name] || existing_resource.display_name,
        (client_authz_resource_representation[:scopes] || []) + existing_resource.scopes.map{|s| {name: s.name}},
        client_authz_resource_representation[:attributes] || existing_resource.attributes
      )

      execute_http do
        RestClient::Resource.new(authz_resources_url(@client_id, resource_id), @configuration.rest_client_options).put(new_resource.to_json, headers)
      end
      get(resource_id)
    end

    def create!(name, type, uris, owner_managed_access, display_name, scopes, attributes = {})
      save(build(name, type, uris, owner_managed_access, display_name, scopes, attributes))
    end

    def find_by(name, type, uris, owner, scope)
      response = execute_http do
        url = "#{authz_resources_url(@client_id)}?name=#{name}&type=#{type}&uris=#{uris}&owner=#{owner}&scope=#{scope}&deep=true&first=0&max=100"
        RestClient::Resource.new(url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzResourceRepresentation.from_hash(role_as_hash) }
    end

    def save(client_authz_resource_representation)
      response = execute_http do
        RestClient::Resource.new(authz_resources_url(@client_id), @configuration.rest_client_options).post(client_authz_resource_representation.to_json, headers)
      end
      ClientAuthzResourceRepresentation.from_hash(JSON.parse(response))
    end

    def delete(resource_id)
      execute_http do
        RestClient::Resource.new(authz_resources_url(@client_id, resource_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def authz_resources_url(client_id, id = nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/resource/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/resource"
      end
    end

    private

    def build(name, type, uris, owner_managed_access, display_name, scopes, attributes={})
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