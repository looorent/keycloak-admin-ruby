RSpec.describe 'ClientAuthorization' do

  before do
    skip unless ENV["GITHUB_ACTIONS"]

    KeycloakAdmin.configure do |config|
      config.use_service_account = false
      config.server_url          = "http://localhost:8080/"
      config.client_id           = "admin-cli"
      config.client_realm_name   = "master"
      config.username            = "admin"
      config.password            = "admin"
      config.rest_client_options = { timeout: 5, verify_ssl: false }
    end
  end

  after do
    configure
  end

  describe "ClientAuthorization Suite" do
    it do
      skip unless ENV["GITHUB_ACTIONS"]

      realm_name = "dummy"

      client = KeycloakAdmin.realm(realm_name).clients.find_by_client_id("dummy-client")
      client.authorization_services_enabled = true
      KeycloakAdmin.realm(realm_name).clients.update(client)

      expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id).list.size).to eql(0)
      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).list.size).to eql(1)
      expect(KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').list.size).to eql(0)

      realm_role =  KeycloakAdmin.realm(realm_name).roles.get("default-roles-dummy")

      scope_1 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_1", "POST 1 scope", "http://asdas")
      scope_2 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_2", "POST 2 scope", "http://asdas")
      expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id).search("POST").first.name).to eql("POST_1")
      expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id).get(scope_1.id).name).to eql("POST_1")

      resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).create!("Dummy Resource", "type", ["/asdf/*", "/tmp/"], true, "display_name", [], {"a": ["b", "c"]})

      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).find_by("Dummy Resource", "", "", "", "").first.name).to eql("Dummy Resource")
      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).find_by("", "type", "", "", "").first.name).to eql("Dummy Resource")

      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).get(resource.id).scopes.count).to eql(0)
      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).get(resource.id).uris.count).to eql(2)
      KeycloakAdmin.realm(realm_name).authz_resources(client.id).update(resource.id,
                                                                             {
                                                                               "name": "Dummy Resource",
                                                                               "type": "type",
                                                                               "owner_managed_access": true,
                                                                               "display_name": "display_name",
                                                                               "attributes": {"a":["b","c"]},
                                                                               "uris": [ "/asdf/*" , "/tmp/45" ],
                                                                               "scopes":[
                                                                                 {name: scope_1.name},{name: scope_2.name}
                                                                               ],
                                                                               "icon_uri": "https://icon.ico"
                                                                             }
      )

      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).get(resource.id).scopes.count).to eql(2)

      policy = KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').create!("Policy 1", "description", "role", "POSITIVE", "UNANIMOUS", true, [{id: realm_role.id, required: true}])
      expect(KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').find_by("Policy 1", "role").first.name).to eql("Policy 1")
      expect(KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').get(policy.id).name).to eql("Policy 1")
      scope_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :scope).create!("Dummy Scope Permission", "scope description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], [scope_1.id, scope_2.id], "")
      resource_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :resource).create!("Dummy Resource Permission", "resource description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], nil, "")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "", resource.id).list.size).to eql(2)
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").get(resource_permission.id).name).to eql("Dummy Resource Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id, resource.id).list.size).to eql(2)

      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'scope').list.size).to eql(3)
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'resource').list.size).to eql(3)
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(resource_permission.name, nil).first.name).to eql("Dummy Resource Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(resource_permission.name, resource.id).first.name).to eql("Dummy Resource Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id).first.name).to eql("Dummy Scope Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id, "POST_1").first.name).to eql("Dummy Scope Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(nil, resource.id).first.name).to eql("Dummy Resource Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(nil, resource.id).first.name).to eql("Dummy Scope Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(nil, resource.id, "POST_1").first.name).to eql("Dummy Scope Permission")
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, nil).first.name).to eql("Dummy Scope Permission")

      KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'scope').delete(scope_permission.id)
      KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'resource').delete(resource_permission.id)
      KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').delete(policy.id)
      KeycloakAdmin.realm(realm_name).authz_resources(client.id).delete(resource.id)
      KeycloakAdmin.realm(realm_name).authz_scopes(client.id).delete(scope_1.id)
      KeycloakAdmin.realm(realm_name).authz_scopes(client.id).delete(scope_2.id)

    end
  end
end
