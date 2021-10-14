require "logger"

require_relative "keycloak-admin/configuration"
require_relative "keycloak-admin/client/client"
require_relative "keycloak-admin/client/client_client"
require_relative "keycloak-admin/client/client_role_mappings_client"
require_relative "keycloak-admin/client/group_client"
require_relative "keycloak-admin/client/realm_client"
require_relative "keycloak-admin/client/role_client"
require_relative "keycloak-admin/client/role_mapper_client"
require_relative "keycloak-admin/client/token_client"
require_relative "keycloak-admin/client/user_client"
require_relative "keycloak-admin/client/identity_provider_client"
require_relative "keycloak-admin/client/configurable_token_client"
require_relative "keycloak-admin/representation/camel_json"
require_relative "keycloak-admin/representation/representation"
require_relative "keycloak-admin/representation/client_representation"
require_relative "keycloak-admin/representation/group_representation"
require_relative "keycloak-admin/representation/token_representation"
require_relative "keycloak-admin/representation/impersonation_redirection_representation"
require_relative "keycloak-admin/representation/impersonation_representation"
require_relative "keycloak-admin/representation/credential_representation"
require_relative "keycloak-admin/representation/realm_representation"
require_relative "keycloak-admin/representation/role_representation"
require_relative "keycloak-admin/representation/federated_identity_representation"
require_relative "keycloak-admin/representation/user_representation"
require_relative "keycloak-admin/representation/identity_provider_representation"
require_relative "keycloak-admin/resource/base_role_containing_resource"
require_relative "keycloak-admin/resource/group_resource"
require_relative "keycloak-admin/resource/user_resource"

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
      config.rest_client_options = {}
    end
  end

  load_configuration
end
