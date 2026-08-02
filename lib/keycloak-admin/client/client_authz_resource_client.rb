# frozen_string_literal: true
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
        resource(authz_resources_url(@client_id)).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzResourceRepresentation.from_hash(role_as_hash) }
    end

    def get(resource_id)
      response = execute_http do
        resource(authz_resources_url(@client_id, resource_id)).get(headers)
      end
      ClientAuthzResourceRepresentation.from_hash(JSON.parse(response))
    end

    def update(resource_id, client_authz_resource_representation)
      submitted = client_authz_resource_representation || {}
      if submitted[:scopes]&.any? { |scope| !scope[:name] }
        raise ArgumentError.new("scope[:name] is mandatory and the only necessary attribute to add scope to resource")
      end

      existing_resource = get(resource_id)
      new_resource = build(
        submitted.fetch(:name, existing_resource.name),
        submitted.fetch(:type, existing_resource.type),
        submitted.fetch(:uris, existing_resource.uris),
        submitted.fetch(:owner_managed_access, existing_resource.owner_managed_access),
        submitted.fetch(:display_name, existing_resource.display_name),
        submitted.fetch(:scopes, existing_resource.scopes.map { |scope| {name: scope.name} }),
        submitted.fetch(:attributes, existing_resource.attributes)
      )

      execute_http do
        resource(authz_resources_url(@client_id, resource_id)).put(new_resource.to_json, headers)
      end
      get(resource_id)
    end

    def create!(name, type, uris, owner_managed_access, display_name, scopes, attributes = {})
      save(build(name, type, uris, owner_managed_access, display_name, scopes, attributes))
    end

    def find_by(name, type, uris, owner, scope)
      response = execute_http do
        url = "#{authz_resources_url(@client_id)}?#{build_query(name: name, type: type, uris: uris, owner: owner, scope: scope, deep: true, first: 0, max: 100)}"
        resource(url).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzResourceRepresentation.from_hash(role_as_hash) }
    end

    def save(client_authz_resource_representation)
      response = execute_http do
        resource(authz_resources_url(@client_id)).post(client_authz_resource_representation.to_json, headers)
      end
      ClientAuthzResourceRepresentation.from_hash(JSON.parse(response))
    end

    def delete(resource_id)
      execute_http do
        resource(authz_resources_url(@client_id, resource_id)).delete(headers)
      end
      true
    end

    def authz_resources_url(client_id, id = nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{encode_segment(client_id)}/authz/resource-server/resource/#{encode_segment(id)}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{encode_segment(client_id)}/authz/resource-server/resource"
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