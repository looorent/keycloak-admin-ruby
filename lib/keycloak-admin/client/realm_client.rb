module KeycloakAdmin
  class RealmClient < Client
    def initialize(configuration, realm_name=nil)
      super(configuration)
      @realm_name = realm_name
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

    def token
      TokenClient.new(@configuration, self)
    end

    def users
      UserClient.new(@configuration, self)
    end

    def name_defined?
      !@realm_name.nil?
    end
  end
end
