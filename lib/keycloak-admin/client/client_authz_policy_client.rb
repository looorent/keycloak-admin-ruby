module KeycloakAdmin
  class ClientAuthzPolicyClient < Client
    def initialize(configuration, realm_client, client_id, type)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      raise ArgumentError.new("type must be defined") unless type
      raise ArgumentError.new("only 'role' policies supported") unless type.to_sym == :role

      @realm_client = realm_client
      @client_id = client_id
      @type = type
    end

    def create!(name, description, type, logic, decision_strategy, fetch_roles, roles)
      response = save(build(name, description, type, logic, decision_strategy, fetch_roles, roles))
      ClientAuthzPolicyRepresentation.from_hash(JSON.parse(response))
    end

    def save(policy_representation)
      execute_http do
        RestClient::Resource.new(authz_policy_url(@client_id, @type), @configuration.rest_client_options).post(
          create_payload(policy_representation), headers
        )
      end
    end

    def get(policy_id)
      response = execute_http do
        RestClient::Resource.new(authz_policy_url(@client_id, @type, policy_id), @configuration.rest_client_options).get(headers)
      end
      ClientAuthzPolicyRepresentation.from_hash(JSON.parse(response))
    end

    def find_by(name, type)
      response = execute_http do
        url = "#{authz_policy_url(@client_id, @type)}?permission=false&name=#{name}&type=#{type}&first=0&max=11"
        RestClient::Resource.new(url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzPolicyRepresentation.from_hash(role_as_hash) }
    end

    def delete(policy_id)
      execute_http do
        RestClient::Resource.new(authz_policy_url(@client_id, @type, policy_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def list
      response = execute_http do
        RestClient::Resource.new(authz_policy_url(@client_id, @type), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzPolicyRepresentation.from_hash(role_as_hash) }
    end

    def authz_policy_url(client_id, type, id = nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/policy/#{type}/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/policy/#{type}?permission=false"
      end
    end

    def build(name, description, type, logic, decision_strategy, fetch_roles, roles=[])
      policy                   = ClientAuthzPolicyRepresentation.new
      policy.name              = name
      policy.description       = description
      policy.type              = type
      policy.logic             = logic
      policy.decision_strategy = decision_strategy
      policy.fetch_roles       = fetch_roles
      policy.roles             = roles
      policy
    end
  end
end