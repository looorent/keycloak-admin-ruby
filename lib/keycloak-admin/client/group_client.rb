module KeycloakAdmin
  class GroupClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def get(group_id)
      response = execute_http do
        RestClient::Resource.new(groups_url(group_id), @configuration.rest_client_options).get(headers)
      end
      GroupRepresentation.from_hash(JSON.parse(response))
    end

    def children(parent_id)
      response = execute_http do
        url = "#{groups_url(parent_id)}/children"
        RestClient::Resource.new(url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |group_as_hash| GroupRepresentation.from_hash(group_as_hash) }
    end

    def list
      search(nil)
    end

    def search(query)
      derived_headers = case query
                        when String
                          headers.merge({params: { search: query }})
                        when Hash
                          headers.merge({params: query })
                        else
                          headers
                        end
      response = execute_http do
        RestClient::Resource.new(groups_url, @configuration.rest_client_options).get(derived_headers)
      end
      JSON.parse(response).map { |group_as_hash| GroupRepresentation.from_hash(group_as_hash) }
    end

    def create!(name, path = nil, attributes = {})
      response = save(build(name, path, attributes))
      created_id(response)
    end

    def save(group_representation)
      execute_http do
        payload = create_payload(group_representation)
        if group_representation.id
          RestClient::Resource.new(groups_url(group_representation.id), @configuration.rest_client_options).put(payload, headers)
        else
          RestClient::Resource.new(groups_url, @configuration.rest_client_options).post(payload, headers)
        end
      end
    end

    def create_subgroup!(parent_id, name, attributes = {})
      url = "#{groups_url(parent_id)}/children"
      response = execute_http do
        RestClient::Resource.new(url, @configuration.rest_client_options).post(
          create_payload(build(name, nil, attributes)), headers
        )
      end
      created_id(response)
    end

    def delete(group_id)
      execute_http do
        RestClient::Resource.new(groups_url(group_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def members(group_id, first=0, max=100)
      url = "#{groups_url(group_id)}/members"
      query = {first: first.try(:to_i), max: max.try(:to_i)}.compact
      unless query.empty?
        query_string = query.to_a.map { |e| "#{e[0]}=#{e[1]}" }.join("&")
        url = "#{url}?#{query_string}"
      end
      response = execute_http do
        RestClient::Resource.new(url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |user_as_hash| UserRepresentation.from_hash(user_as_hash) }
    end

    # Gets all realm-level roles for a group
    def get_realm_level_roles(group_id)
      url = "#{groups_url(group_id)}/role-mappings/realm"
      response = execute_http do
        RestClient::Resource.new(url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| RoleRepresentation.from_hash(role_as_hash) }
    end

    # Adds a realm-level role to a group via the role name
    def add_realm_level_role_name!(group_id, role_name)
      # creates a full role-representation object needed by the keycloak api to work
      role_representation = RoleClient.new(@configuration, @realm_client).get(role_name)
      url = "#{groups_url(group_id)}/role-mappings/realm"
      response = execute_http do
        RestClient::Resource.new(url, @configuration.rest_client_options).post(
          create_payload([role_representation]), headers
        )
      end
      role_representation
    end

    # Remove a realm-level role from a group by the role name
    def remove_realm_level_role_name!(group_id, role_name)
      role_representation = RoleClient.new(@configuration, @realm_client).get(role_name)
      url = "#{groups_url(group_id)}/role-mappings/realm"
      execute_http do
        RestClient::Request.execute(
          @configuration.rest_client_options.merge(
            url:,
            method: :delete,
            payload: create_payload([role_representation]),
            headers: headers
          )
        )
      end
      true
    end

    def groups_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/groups/#{id}"
      else
        "#{@realm_client.realm_admin_url}/groups"
      end
    end

    private

    def build(name, path, attributes)
      GroupRepresentation.from_hash(
        {
          "name" => name,
          "path" => path,
          "attributes" => attributes
        }
      )
    end
  end
end
