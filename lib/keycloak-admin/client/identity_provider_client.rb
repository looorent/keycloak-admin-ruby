module KeycloakAdmin
  class IdentityProviderClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def create(identity_provider_representation)
      execute_http do
        RestClient::Resource.new(identity_providers_url, @configuration.rest_client_options).post(
          create_payload(identity_provider_representation), headers
        )
      end
    end

    def add_mapping(identity_provider_alias, identity_provider_mapping_representation)
      execute_http do
        RestClient::Resource.new(identity_provider_mappers_url(identity_provider_alias), @configuration.rest_client_options).post(
          create_payload(identity_provider_mapping_representation), headers
        )
      end
    end

    def list
      response = execute_http do
        RestClient::Resource.new(identity_providers_url, @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |provider_as_hash| IdentityProviderRepresentation.from_hash(provider_as_hash) }
    end

    def get(internal_id_or_alias=nil)
      response = execute_http do
        RestClient::Resource.new(identity_providers_url(internal_id_or_alias), @configuration.rest_client_options).get(headers)
      end
      IdentityProviderRepresentation.from_hash(JSON.parse(response))
    end

    def identity_providers_url(internal_id_or_alias=nil)
      if internal_id_or_alias
        "#{@realm_client.realm_admin_url}/identity-provider/instances/#{internal_id_or_alias}"
      else
        "#{@realm_client.realm_admin_url}/identity-provider/instances"
      end
    end

    def identity_provider_mappers_url(internal_id_or_alias)
      "#{identity_providers_url(internal_id_or_alias)}/mappers"
    end
  end
end
