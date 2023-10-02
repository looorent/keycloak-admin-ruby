module KeycloakAdmin
  class ClientClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def get(id)
      response = execute_http do
        RestClient::Resource.new(clients_url(id), @configuration.rest_client_options).get(headers)
      end
      ClientRepresentation.from_hash(JSON.parse(response))
    end

    def save(client_representation)
      execute_http do
        RestClient::Resource.new(clients_url, @configuration.rest_client_options).post(
          create_payload(client_representation), headers
        )
      end
    end

    def list
      response = execute_http do
        RestClient::Resource.new(clients_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |client_as_hash| ClientRepresentation.from_hash(client_as_hash) }
    end

    def delete(id)
      execute_http do
        RestClient::Resource.new(clients_url(id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def get_service_account_user(client_id)
      response = execute_http do
        RestClient::Resource.new(service_account_user_url(client_id), @configuration.rest_client_options).get(headers)
      end
      UserRepresentation.from_hash(JSON.parse(response))
    end

    def clients_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients"
      end
    end

    def service_account_user_url(client_id)
      "#{clients_url(client_id)}/service-account-user"
    end
  end
end
