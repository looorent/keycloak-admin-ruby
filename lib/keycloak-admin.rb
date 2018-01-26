require "logger"

require_relative "keycloak-admin/configuration"
require_relative "keycloak-admin/client/client"
require_relative "keycloak-admin/client/realm_client"
require_relative "keycloak-admin/client/token_client"
require_relative "keycloak-admin/client/user_client"
require_relative "keycloak-admin/client/configurable_token_client"
require_relative "keycloak-admin/representation/camel_json"
require_relative "keycloak-admin/representation/representation"
require_relative "keycloak-admin/representation/token_representation"
require_relative "keycloak-admin/representation/impersonation_redirection_representation"
require_relative "keycloak-admin/representation/impersonation_representation"
require_relative "keycloak-admin/representation/credential_representation"
require_relative "keycloak-admin/representation/user_representation"

module KeycloakAdmin

  def self.configure
    yield @configuration ||= KeycloakAdmin::Configuration.new
  end

  def self.config
    @configuration
  end

  def self.realm(realm_name)
    RealmClient.new(@configuration, realm_name)
  end

  def self.logger
    config.logger
  end

  def self.load_configuration
    configure do |config|
      config.server_url          = nil
      config.server_domain       = nil
      config.client_realm_name   = ""
      config.client_id           = "admin-cli"
      config.logger              = ::Logger.new(STDOUT)
      config.use_service_account = true
      config.username            = nil
      config.password            = nil
    end
  end

  load_configuration
end
