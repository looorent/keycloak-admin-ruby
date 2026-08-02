module KeycloakAdmin
  class ClientScopeClient < Client
    def initialize(configuration, realm_client)
      super(configuration)

      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?

      @realm_client = realm_client
    end

    def list
      response = execute_http do
        resource(client_scopes_url).get(headers)
      end

      JSON.parse(response).map { |h| ClientScopeRepresentation.from_hash(h) }
    end

    def get(client_scope_id)
      response = execute_http do
        resource(client_scopes_url(client_scope_id)).get(headers)
      end

      ClientScopeRepresentation.from_hash(JSON.parse(response))
    end

    def create!(client_scope_representation)
      execute_http do
        resource(client_scopes_url).post(
          create_payload(client_scope_representation), headers
        )
      end

      true
    end

    def save(client_scope_representation)
      execute_http do
        resource(client_scopes_url(client_scope_representation.id)).put(
          create_payload(client_scope_representation), headers
        )
      end

      true
    end

    def search(name)
      list.select { |scope| scope&.name&.include?(name) }
    end

    def delete(client_scope_id)
      execute_http do
        resource(client_scopes_url(client_scope_id)).delete(headers)
      end

      true
    end

    def client_scopes_url(client_scope_id = nil)
      base = "#{@realm_client.realm_admin_url}/client-scopes"

      client_scope_id ? "#{base}/#{encode_segment(client_scope_id)}" : base
    end
  end
end
