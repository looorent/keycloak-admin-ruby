module KeycloakAdmin
  class AttackDetectionClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    def lock_status(user_id)
      raise ArgumentError.new('user_id must be defined') if user_id.blank?

      response = execute_http do
        RestClient::Resource.new(brute_force_url(user_id), @configuration.rest_client_options).get(headers)
      end
      AttackDetectionRepresentation.from_hash(JSON.parse(response))
    end

    def unlock_user(user_id)
      raise ArgumentError.new('user_id must be defined') if user_id.blank?

      execute_http do
        RestClient::Resource.new(brute_force_url(user_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def unlock_users
      execute_http do
        RestClient::Resource.new(brute_force_url, @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def brute_force_url(user_id = nil)
      if user_id
        "#{@realm_client.realm_admin_url}/attack-detection/brute-force/users/#{user_id}"
      else
        "#{@realm_client.realm_admin_url}/attack-detection/brute-force/users"
      end
    end
  end
end