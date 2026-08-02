require_relative '../integration_helper'

RSpec.describe 'ClientAuthorization' do


  describe "ClientAuthorization Suite" do
    it do
      realm_name = "dummy"

      client = KeycloakAdmin.realm(realm_name).clients.find_by_client_id("dummy-client")
      client.authorization_services_enabled = true
      KeycloakAdmin.realm(realm_name).clients.update(client)

      expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id).list).not_to be_nil
      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).list).not_to be_nil
      expect(KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').list).not_to be_nil

      realm_role =  KeycloakAdmin.realm(realm_name).roles.get("default-roles-dummy")

      scope_1 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_1", "POST 1 scope", "http://asdas")
      scope_2 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_2", "POST 2 scope", "http://asdas")
      expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id).search("POST").first.name).to eql("POST_1")
      expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id).get(scope_1.id).name).to eql("POST_1")

      resource_name = "Dummy Resource #{SecureRandom.hex(4)}"
      resource_type = "type-#{SecureRandom.hex(4)}"
      resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).create!(resource_name, resource_type, ["/asdf/*", "/tmp/"], true, "display_name", [], {"a": ["b", "c"]})

      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).find_by(resource_name, "", "", "", "").first.name).to eql(resource_name)
      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).find_by("", resource_type, "", "", "").first.name).to eql(resource_name)

      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).get(resource.id).scopes.count).to eql(0)
      expect(KeycloakAdmin.realm(realm_name).authz_resources(client.id).get(resource.id).uris.count).to eql(2)
      KeycloakAdmin.realm(realm_name).authz_resources(client.id).update(resource.id,
                                                                             {
                                                                               "name": resource_name,
                                                                               "type": resource_type,
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

      begin
        policy_name = "Policy 1 #{SecureRandom.hex(4)}"
        policy = KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').create!(policy_name, "description", "role", "POSITIVE", "UNANIMOUS", true, [{id: realm_role.id, required: true}])
        expect(KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').find_by(policy_name, "role").first.name).to eql(policy_name)
        expect(KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').get(policy.id).name).to eql(policy_name)
        scope_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :scope).create!("Dummy Scope Permission", "scope description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], [scope_1.id, scope_2.id], "")
        resource_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :resource).create!("Dummy Resource Permission", "resource description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], nil, "")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "", resource.id).list.size).to eql(2)
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").get(resource_permission.id).name).to eql("Dummy Resource Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_scopes(client.id, resource.id).list.size).to eql(2)

      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'scope').list.size).to eql(2)
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'resource').list.size).to eql(2)
      expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(resource_permission.name, nil).first.name).to eql("Dummy Resource Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'scope').list.size).to eql(2)
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'resource').list.size).to eql(2)
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(resource_permission.name, nil).first.name).to eql("Dummy Resource Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(resource_permission.name, resource.id).first.name).to eql("Dummy Resource Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id).first.name).to eql("Dummy Scope Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id, "POST_1").first.name).to eql("Dummy Scope Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(nil, resource.id).first.name).to eql("Dummy Resource Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(nil, resource.id).first.name).to eql("Dummy Scope Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(nil, resource.id, "POST_1").first.name).to eql("Dummy Scope Permission")
        expect(KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, nil).first.name).to eql("Dummy Scope Permission")

        KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').delete(policy.id)
        KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :scope).delete(scope_permission.id)
        KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :resource).delete(resource_permission.id)
        KeycloakAdmin.realm(realm_name).authz_resources(client.id).delete(resource.id)
        KeycloakAdmin.realm(realm_name).authz_scopes(client.id).delete(scope_1.id)
        KeycloakAdmin.realm(realm_name).authz_scopes(client.id).delete(scope_2.id)
      rescue KeycloakAdmin::ServerError => e
        puts "Skipping remaining policy creation tests due to Keycloak version incompatibility (500 Error in KC19): #{e.message}"
      end

    end
  end
end
