module KeycloakAdmin
  class ClientScopeProtocolMapperClient < Client
    def initialize(configuration, realm_client, client_scope_id)
      super(configuration)

      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?

      @realm_client    = realm_client
      @client_scope_id = client_scope_id
    end

    def list
      response = execute_http do
        resource(protocol_mappers_url).get(headers)
      end

      JSON.parse(response).map { |h| ProtocolMapperRepresentation.from_hash(h) }
    end

    def get(mapper_id)
      response = execute_http do
        resource(protocol_mappers_url(mapper_id)).get(headers)
      end

      ProtocolMapperRepresentation.from_hash(JSON.parse(response))
    end

    def create!(mapper_representation)
      execute_http do
        resource(protocol_mappers_url).post(
          create_payload(mapper_representation), headers
        )
      end

      true
    end

    def save(mapper_representation)
      execute_http do
        resource(protocol_mappers_url(mapper_representation.id)).put(
          create_payload(mapper_representation), headers
        )
      end

      true
    end

    def delete(mapper_id)
      execute_http do
        resource(protocol_mappers_url(mapper_id)).delete(headers)
      end

      true
    end

    def protocol_mappers_url(mapper_id = nil)
      base = "#{@realm_client.realm_admin_url}/client-scopes/#{encode_segment(@client_scope_id)}/protocol-mappers/models"

      mapper_id ? "#{base}/#{encode_segment(mapper_id)}" : base
    end
  end
end
