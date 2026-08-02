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
        resource(authz_permission_url(@client_id, nil, @type, permission_id)).delete(headers)
      end
      true
    end

    def find_by(name, resource_param, scope = nil)
      response = execute_http do
        url = "#{authz_permission_url(@client_id)}?#{build_query(name: name, resource: resource_param, type: @type, scope: scope, deep: true, first: 0, max: 100)}"
        resource(url).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzPermissionRepresentation.from_hash(role_as_hash) }
    end

    def create!(name, description, decision_strategy,logic = "POSITIVE", resources = [], policies = [], scopes = [], resource_type = nil)
      response = save(build(name, description, decision_strategy, logic, resources, policies, scopes, resource_type))
      ClientAuthzPermissionRepresentation.from_hash(JSON.parse(response))
    end

    def save(permission_representation)
      execute_http do
        resource(authz_permission_url(@client_id, nil, permission_representation.type)).post(
          create_payload(permission_representation), headers
        )
      end
    end

    def list
      response = execute_http do
        resource(authz_permission_url(@client_id, @resource_id)).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzPermissionRepresentation.from_hash(role_as_hash) }
    end

    def get(permission_id)
      response = execute_http do
        resource(authz_permission_url(@client_id, nil, @type, permission_id)).get(headers)
      end
      ClientAuthzPermissionRepresentation.from_hash(JSON.parse(response))
    end

    def authz_permission_url(client_id, resource_id = nil, type = nil, id = nil)
      if resource_id
        "#{@realm_client.realm_admin_url}/clients/#{encode_segment(client_id)}/authz/resource-server/resource/#{encode_segment(resource_id)}/permissions"
      elsif id
        "#{@realm_client.realm_admin_url}/clients/#{encode_segment(client_id)}/authz/resource-server/permission/#{encode_segment(type)}/#{encode_segment(id)}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{encode_segment(client_id)}/authz/resource-server/permission/#{encode_segment(type)}"
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