module KeycloakAdmin
  class ClientClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def list
      response = execute_http do
        RestClient::Resource.new(clients_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |client_as_hash| ClientRepresentation.from_hash(client_as_hash) }
    end

    def clients_url(id=nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients"
      end
    end
  end
end
