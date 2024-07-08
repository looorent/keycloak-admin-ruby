module KeycloakAdmin
  class ClientAuthzPermissionClient < Client
    def initialize(configuration, realm_client, client_id, type, resource_id = nil)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      raise ArgumentError.new("bad permission type") if !resource_id && !%i[resource scope].include?(type.to_sym)

      @realm_client = realm_client
      @client_id = client_id
      @type = type
      @resource_id = resource_id
    end

    def delete(permission_id)
      execute_http do
        RestClient::Resource.new(authz_permission_url(@client_id, nil, nil, permission_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def find_by(name, resource, scope = nil)
      response = execute_http do
        url = "#{authz_permission_url(@client_id)}?name=#{name}&resource=#{resource}&type=#{@type}&scope=#{scope}&deep=true&first=0&max=100"
        RestClient::Resource.new(url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzPermissionRepresentation.from_hash(role_as_hash) }
    end

    def create!(name, description, decision_strategy,logic = "POSITIVE", resources = [], policies = [], scopes = [], resource_type = nil)
      response = save(build(name, description, decision_strategy, logic, resources, policies, scopes, resource_type))
      ClientAuthzPermissionRepresentation.from_hash(JSON.parse(response))
    end

    def save(permission_representation)
      execute_http do
        RestClient::Resource.new(authz_permission_url(@client_id, nil, permission_representation.type), @configuration.rest_client_options).post(
          create_payload(permission_representation), headers
        )
      end
    end

    def list
      response = execute_http do
        RestClient::Resource.new(authz_permission_url(@client_id, @resource_id), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzPermissionRepresentation.from_hash(role_as_hash) }
    end

    def get(permission_id)
      response = execute_http do
        RestClient::Resource.new(authz_permission_url(@client_id, nil, @type, permission_id), @configuration.rest_client_options).get(headers)
      end
      ClientAuthzPermissionRepresentation.from_hash(JSON.parse(response))
    end

    def authz_permission_url(client_id, resource_id = nil, type = nil, id = nil)
      if resource_id
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/resource/#{resource_id}/permissions"
      elsif id
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/permission/#{type}/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/permission/#{type}"
      end
    end

    def build(name, description, decision_strategy, logic, resources, policies, scopes, resource_type)
      policy                   = ClientAuthzPermissionRepresentation.new
      policy.name              = name
      policy.description       = description
      policy.type              = @type
      policy.decision_strategy = decision_strategy
      policy.resource_type     = resource_type
      policy.resources         = resources
      policy.policies          = policies
      policy.scopes            = scopes
      policy.logic             = logic
      policy
    end

  end
end