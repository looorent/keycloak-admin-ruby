module KeycloakAdmin
  class RealmClient < Client
    def initialize(configuration, realm_name=nil)
      super(configuration)
      @realm_name = realm_name
    end

    def list
      response = execute_http do
        RestClient::Resource.new(realm_list_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |realm_as_hash| RealmRepresentation.from_hash(realm_as_hash) }
    end

    def realm_url
      if @realm_name
        "#{server_url}/realms/#{@realm_name}"
      else
        "#{server_url}/realms"
      end
    end

    def realm_admin_url
      if @realm_name
        "#{server_url}/admin/realms/#{@realm_name}"
      else
        "#{server_url}/admin/realms"
      end
    end

    def realm_list_url
      "#{server_url}/admin/realms"
    end

    def token
      TokenClient.new(@configuration, self)
    end

    def configurable_token
      ConfigurableTokenClient.new(@configuration, self)
    end

    def users
      UserClient.new(@configuration, self)
    end

    def name_defined?
      !@realm_name.nil?
    end
  end
end
