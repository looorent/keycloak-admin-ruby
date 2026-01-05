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

    def delete
      execute_http do
        RestClient::Resource.new(realm_admin_url, @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def save(realm_representation)
      execute_http do
        RestClient::Resource.new(realm_list_url, @configuration.rest_client_options).post(
          create_payload(realm_representation), headers
        )
      end
    end

    def update(realm_representation_body)
      execute_http do
        RestClient::Resource.new(realm_admin_url, @configuration.rest_client_options).put(
          create_payload(realm_representation_body), headers
        )
      end
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

    def clients
      ClientClient.new(@configuration, self)
    end

    def groups
      GroupClient.new(@configuration, self)
    end

    def group(group_id)
      GroupResource.new(@configuration, self, group_id)
    end

    def roles
      RoleClient.new(@configuration, self)
    end

    def client_roles
      ClientRoleClient.new(@configuration, self)
    end

    def users
      UserClient.new(@configuration, self)
    end

    def attack_detections
      AttackDetectionClient.new(@configuration, self)
    end

    def identity_providers
      IdentityProviderClient.new(@configuration, self)
    end

    def organizations
      OrganizationClient.new(@configuration, self)
    end

    def user(user_id)
      UserResource.new(@configuration, self, user_id)
    end

    def authz_scopes(client_id, resource_id = nil)
      ClientAuthzScopeClient.new(@configuration, self, client_id, resource_id)
    end

    def authz_resources(client_id)
      ClientAuthzResourceClient.new(@configuration, self, client_id)
    end

    def authz_permissions(client_id, type, resource_id = nil)
      ClientAuthzPermissionClient.new(@configuration, self, client_id, type, resource_id)
    end

    def authz_policies(client_id, type)
      ClientAuthzPolicyClient.new(@configuration, self, client_id, type)
    end

    def name_defined?
      !@realm_name.nil?
    end
  end
end
