
# Keycloak Admin Ruby

Ruby client that acts as a client for the Keycloak REST API.
This gem basically acts as an url builder using `http-client` to get responses and serialize them into _representation_ objects.

_Warning: This beta gem is currently used for personal use. Most Keycloak Admin features are not implemented yet._

## Install

This gem *does not* require Rails.
For example, using `bundle`, add this line to your Gemfile.

```ruby
gem "keycloak-admin", "1.1.6"
```

## Login

To login on Keycloak's Admin API, you first need to setup a client.

Go to your realm administration page and open `Clients`. Then, click on the `Create` button.
On the first screen, enter:
* `Client ID`: _e.g. my-app-admin-client_
* `Client Protocol`: select `openid-connect`
* `Root URL`: let it blank

The next screen must be configured depending on how you want to authenticate:
* `username/password` with a user of the realm
* `Direct Access Grants` with a service account

### Login with username/password (realm user)

* In Keycloak, during the client setup:
  * `Access Type`: `public` or `confidential`
  * `Service Accounts Enabled` (when `confidential`): `false`
  * After saving your client, if you have chosen a `confidential` client, go to `Credentials` tab and copy the `Client Secret`

* In Keycloak, create a dedicated user (and her credentials):
  * Go to `Users`
  * Click on the `Add user` button
  * Setup her mandatory information, depending on your realm's configuration
  * On the `Credentials` tab, create her a password (toggle off `Temporary`)

* In this gem's configuration (see Section `Configuration`):
  * Setup `username` and `password` according to your user's configuration
  * Setup `client_id` with your `Client ID` (_e.g. my-app-admin-client_)
  * If your client is `confidential`, copy its Client Secret to `client_secret`

### Login with `Direct Access Grants` (Service account)

Using a service account to use the REST Admin API does not require to create a dedicated user (https://www.keycloak.org/docs/latest/server_admin/#_service_accounts).

* In Keycloak, during the client setup:
  * `Access Type`:  `confidential`
  * `Service Accounts Enabled` (when `confidential`): `true`
  * `Standard Flow Enabled`: `false`
  * `Implicit Flow Enabled`: `false`
  * `Direct Access Grants Enabled`: `true`
  * After saving this client
    * open the `Service Account Roles` and add relevant `realm-management.` client's roles. For instance: `view-users` if you want to search for users using this gem.
    * open the `Credentials` tab and copy the `Client Secret`

* In this gem's configuration  (see Section `Configuration`):
  * Set `use_service_account` to `true`
  * Setup `client_id` with your `Client ID` (_e.g. my-app-admin-client_)
  * Copy its Client Secret to `client_secret`

## Configuration

To configure this gem, call `KeycloakAdmin.configure`.
For instance, to configure this gem based on environment variables, write (and load if required) a `keycloak_admin.rb`:
```ruby
KeycloakAdmin.configure do |config|
  config.use_service_account = false
  config.server_url          = ENV["KEYCLOAK_SERVER_URL"]
  config.server_domain       = ENV["KEYCLOAK_SERVER_DOMAIN"]
  config.client_id           = ENV["KEYCLOAK_ADMIN_CLIENT_ID"]
  config.client_realm_name   = ENV["KEYCLOAK_REALM_ID"]
  config.username            = ENV["KEYCLOAK_ADMIN_USER"]
  config.password            = ENV["KEYCLOAK_ADMIN_PASSWORD"]
  config.logger              = Rails.logger

  # You configure RestClient to your liking – see https://github.com/rest-client/rest-client/blob/master/lib/restclient/request.rb for available options.
  config.rest_client_options = { timeout: 5 }
end
```
This example is autoloaded in a Rails environment.

### Overall configuration options

All options have a default value. However, all of them can be changed in your initializer file.

| Option | Default Value | Type | Required? | Description  | Example |
| ---- | ----- | ------ | ----- | ------ | ----- |
| `server_url` | `nil` | String | Required | The base url where your Keycloak server is located (a URL that starts with `http` and that ends with `/auth`). This value can be retrieved in your Keycloak client configuration. | `http://auth:8080/auth`
| `server_domain` | `nil`| String | Required | Public domain that identify your authentication cookies. | `auth.service.io` |
| `client_realm_name` | `""`| String | Required | Name of the realm that contains the admin client. | `master` |
| `client_id` | `admin-cli`| String | Required | Client that should be used to access admin capabilities. | `api-cli` |
| `client_secret` | `nil`| String | Optional | If your client is `confidential`, this parameter must be specified. | `4e3c481c-f823-4a6a-b8a7-bf8c86e3eac3` |
| `use_service_account` | `true` | Boolean | Required | `true` if the connection to the client uses a Service Account. `false` if the connection to the client uses a username/password credential. | `false` |
| `username` | `nil`| String | Optional | Username to access the Admin REST API. Recommended if `user_service_account` is set to `false`. | `mummy` |
| `password` | `nil`| String | Optional | Clear password to access the Admin REST API. Recommended if `user_service_account` is set to `false`. | `bobby` |
| `logger` | `Logger.new(STDOUT)`| Logger | Optional | The logger used by `keycloak-admin` | `Rails.logger` | 
| `rest_client_options` | `{}`| Hash | Optional | Options to pass to `RestClient` | `{ timeout: 5 }` | 


## Use Cases

### Supported features

* Get an access token
* Create/update/get/delete a user
* Get list of users, search for user(s)
* List credentials of a user
* Reset credentials
* Impersonate a user
* Exchange a configurable token
* Get list of clients, or find a client by its id or client_id
* Create, update, and delete clients
* Get list of groups, create/save a group
* Get list of roles, save a role
* Get list of realms, save/update/delete a realm
* Get list of client role mappings for a user/group
* Get list of members of a group
* Get list of groups that have a specific role assigned
* Get list of realm-roles assigned to a group, add a realm-role to a group
* Save client role mappings for a user/group
* Save realm-level role mappings for a user/group
* Add a Group on a User
* Remove a Group from a User
* Get list of Identity Providers
* Create Identity Providers
* Link/Unlink users to federated identity provider brokers
* Execute actions emails
* Send forgot passsword mail
* Client Authorization, create, update, get, delete Resource, Scope, Policy, Permission, Policy Enforcer
* Get list of organizations, create/update/get/delete an organization
* Get list of members of an organization, add/remove members
* Invite new or existing users to an organization
* List, add, and remove Identity Providers for an organization
* Get list of organizations associated with a specific user

### Get an access token

Returns an instance of `KeycloakAdmin::TokenRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").token.get
```

### Get a user from its identifier

Returns an instance of `KeycloakAdmin::UserRepresentation` or `nil` when this user does not exist.

```ruby
user_id = "95985b21-d884-4bbd-b852-cb8cd365afc2"
KeycloakAdmin.realm("a_realm").users.get(user_id)
```

### Search for users

Returns an array of `KeycloakAdmin::UserRepresentation`.

According to [the documentation](https://www.keycloak.org/docs-api/11.0/rest-api/index.html#_users_resource):
* When providing a `String` parameter, this produces an arbitrary search string
* When providing a `Hash`, you can search for specific field (_e.g_ an email)

```ruby
KeycloakAdmin.realm("a_realm").users.search("a_username_or_an_email")
```

```ruby
KeycloakAdmin.realm("a_realm").users.search({ email: "john@doe.com" })
```

### List all users in a realm

Returns an array of `KeycloakAdmin::UserRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").users.list
```

### Save a user

Returns the provided `user`, which must be of type `KeycloakAdmin::UserRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").users.save(user)
```

### Update a user

If you want to update its entire entity. To update some specific attributes, provide an object implementing `to_json`, such as a `Hash`.

```ruby
KeycloakAdmin.realm("a_realm").users.update("05c135c6-5ad8-4e17-b1fa-635fc089fd71", {
  email: "hello@gmail.com",
  username: "hello",
  first_name: "Jean",
  last_name: "Dupond"
})
```

Attention point: Since Keycloak 24.0.4, when updating a user, all the writable profile attributes must be passed, otherwise they will be removed. (https://www.keycloak.org/docs/24.0.4/upgrading/)

### Delete a user

```ruby
KeycloakAdmin.realm("a_realm").users.delete(user_id)
```

### Create and save a user with password and a locale

Returns the created user of type `KeycloakAdmin::UserRepresentation`.

```ruby
username       = "pioupioux"
email          = "pioupioux@email.com"
password       = "acme0"
email_verified = true
locale         = "en"
KeycloakAdmin.realm("a_realm").users.create!(username, email, password, email_verified, locale)
```

### Reset a password

```ruby
user_id      = "95985b21-d884-4bbd-b852-cb8cd365afc2"
new_password = "coco"
KeycloakAdmin.realm("a_realm").users.update_password(user_id, new_password)
```

### List credentials

```ruby
user_id      = "95985b21-d884-4bbd-b852-cb8cd365afc2"
KeycloakAdmin.realm("a_realm").users.credentials(user_id)
```

### Impersonate a password directly

Returns an instance of `KeycloakAdmin::ImpersonationRepresentation`.

```ruby
user_id = "95985b21-d884-4bbd-b852-cb8cd365afc2"
KeycloakAdmin.realm("a_realm").users.impersonate(user_id)
```

### Impersonate a password indirectly

To have enough information to execute an impersonation by yourself, `get_redirect_impersonation` returns an instance of `KeycloakAdmin::ImpersonationRedirectionRepresentation`.

```ruby
user_id = "95985b21-d884-4bbd-b852-cb8cd365afc2"
KeycloakAdmin.realm("a_realm").users.get_redirect_impersonation(user_id)
```

### List all the organizations of a realm

```ruby
KeycloakAdmin.realm("a_realm").organizations.list
```

### Exchange a configurable token

*Requires your Keycloak server to have deployed the Custom REST API `configurable-token`* (https://github.com/looorent/keycloak-configurable-token-api)
Returns an instance of `KeycloakAdmin::TokenRepresentation`.

```ruby
user_access_token         = "abqsdofnqdsogn"
token_lifespan_in_seconds = 20
KeycloakAdmin.realm("a_realm").configurable_token.exchange_with(user_access_token, token_lifespan_in_seconds)
```

### Get list of realms

Returns an array of `KeycloakAdmin::RealmRepresentation`.

```ruby
KeycloakAdmin.realm("master").list
```

### Save a realm

Takes `realm` of type `KeycloakAdmin::RealmRepresentation`, or an object implementing `to_json`, such as a `Hash`.

```ruby
KeycloakAdmin.realm(nil).save(realm)
```

### Update a realm

If you want to update its entire entity. To update some specific attributes, provide an object implementing `to_json`, such as a `Hash`.

```ruby
KeycloakAdmin.realm("a_realm").update({
  smtpServer: { host: 'test_host' }
})
```

### Delete a realm

```ruby
KeycloakAdmin.realm("a_realm").delete
```

### Get list of clients in a realm

Returns an array of `KeycloakAdmin::ClientRepresentation` or a single `KeycloakAdmin::ClientRepresentation`

Finding a client by its `client_id` is a somewhat slow operation, as it requires fetching all clients and then filtering. Keycloak's API does not support fetching a client by its `client_id` directly.

```ruby
KeycloakAdmin.realm("a_realm").clients.list
KeycloakAdmin.realm("a_realm").clients.get(id) # id is Keycloak's database id, not the client_id
KeycloakAdmin.realm("a_realm").clients.find_by_client_id(client_id)
```

### Updating a client

```ruby
my_client = KeycloakAdmin.realm("a_realm").clients.get(id)

my_client.name        = "My new client name"
my_client.description = "This is a new description"
my_client.redirect_uris << "https://www.example.com/auth/callback"

KeycloakAdmin.realm("a_realm").clients.update(client) # Returns the updated client
```

### Get list of groups in a realm

Returns an array of `KeycloakAdmin::GroupRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").groups.list
```

### Search for a group

Returns an array of `KeycloakAdmin::GroupRepresentation`.

According to [the documentation](https://www.keycloak.org/docs-api/22.0.1/rest-api/index.html#_groups):
* When providing a `String` parameter, this produces an arbitrary search string
* When providing a `Hash`, you can specify other fields (_e.g_ q, max, first)

```ruby
KeycloakAdmin.realm("a_realm").groups.search("MyGroup")
```

```ruby
KeycloakAdmin.realm("a_realm").groups.search({query: "MyGroup", exact: true, max: 1})
```

### Save a group

Returns the id of saved `group` provided, which must be of type `KeycloakAdmin::GroupRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").groups.save(group)
```

### Create and save a group with a name and path

Returns the id of created group.

```ruby
group_name = "test"
group_path = "/top"
group_id = KeycloakAdmin.realm("a_realm").groups.create!(group_name, group_path)
```

### Create a new subgroup of an existing group

Create a new group as the child of an existing group.

```ruby
parent_id = "7686af34-204c-4515-8122-78d19febbf6e"
group_name = "test"
sub_group_id = KeycloakAdmin.realm("a_realm").groups.create_subgroup!(parent_id, group_name)
```

### Get list of members of a group

Returns an array of `KeycloakAdmin::UserRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").group("group_id").members
```

You can specify paging with `first` and `max`:

```ruby
KeycloakAdmin.realm("a_realm").group("group_id").members(first:0, max:100)
```

### Get list of groups that have a specific role assigned

Returns an array of `KeycloakAdmin::GroupRepresentation`

```ruby
KeycloakAdmin.realm("a_realm").roles.list_groups("role_name")
```

### Get list of realm-roles assigned to a group

Returns an array of `KeycloakAdmin::RoleRepresentation`

```ruby
KeycloakAdmin.realm("a_realm").groups.get_realm_level_roles("group_id")
```

### Add a realm-role to a group

Returns added `KeycloakAdmin::RoleRepresentation`

```ruby
KeycloakAdmin.realm("a_realm").groups.add_realm_level_role_name!("group_id", "role_name")
```

### Get list of roles in a realm

Returns an array of `KeycloakAdmin::RoleRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").roles.list
```

### Save a role

Takes `role`, which must be of type `KeycloakAdmin::RoleRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").roles.save(role)
```

### Get list of client role mappings for a user/group

Returns an array of `KeycloakAdmin::RoleRepresentation`.

```ruby
user_id   = "95985b21-d884-4bbd-b852-cb8cd365afc2"
client_id = "1869e876-71b4-4de2-849e-66540db3a098"
KeycloakAdmin.realm("a_realm").user(user_id).client_role_mappings(client_id).list_available
```
or
```ruby
group_id  = "3a63b5c0-ef8a-47fd-86ed-b5fead18d9b8"
client_id = "1869e876-71b4-4de2-849e-66540db3a098"
KeycloakAdmin.realm("a_realm").group(group_id).client_role_mappings(client_id).list_available
```

### Save list of client role mappings for a user/group

Takes `role_list`, which must be an array of type `KeycloakAdmin::RoleRepresentation`.

```ruby
user_id   = "95985b21-d884-4bbd-b852-cb8cd365afc2"
client_id = "1869e876-71b4-4de2-849e-66540db3a098"
KeycloakAdmin.realm("a_realm").user(user_id).client_role_mappings(client_id).save(role_list)
```
or
```ruby
group_id  = "3a63b5c0-ef8a-47fd-86ed-b5fead18d9b8"
client_id = "1869e876-71b4-4de2-849e-66540db3a098"
KeycloakAdmin.realm("a_realm").group(group_id).client_role_mappings(client_id).save(role_list)
```

### Save list of realm-level role mappings for a user/group

Takes `role_list`, which must be an array of type `KeycloakAdmin::RoleRepresentation`.

```ruby
user_id   = "95985b21-d884-4bbd-b852-cb8cd365afc2"
KeycloakAdmin.realm("a_realm").user(user_id).role_mapper.save_realm_level(role_list)
```
or
```ruby
group_id  = "3a63b5c0-ef8a-47fd-86ed-b5fead18d9b8"
KeycloakAdmin.realm("a_realm").group(group_id).role_mapper.save_realm_level(role_list)
```

### Get list of identity providers

Note: This client requires the `realm-management.view-identity-providers` role.

Returns an array of `KeycloakAdmin::IdentityProviderRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").identity_providers.list
```

### Manage [Client Authorization Resources & Scopes](https://www.keycloak.org/docs/latest/authorization_services/index.html#_resource_overview)

In order to use authorization, you need to enable the client's `authorization_services_enabled` attribute.

```ruby
client_id = "dummy-client"
client = KeycloakAdmin.realm("realm_a").clients.find_by_client_id(client_id)
client.authorization_services_enabled = true
KeycloakAdmin.realm("a_realm").clients.update(client)
```

### Create a scope

Returns added `KeycloakAdmin::ClientAuthzScopeRepresentation`

```ruby
KeycloakAdmin.realm("a_realm").authz_scopes(client_id).create!("POST_1", "POST 1 scope description", "http://icon.url")
````

### Search for scope

Returns array of `KeycloakAdmin::ClientAuthzScopeRepresentation`

```ruby
KeycloakAdmin.realm("a_realm").authz_scopes(client.id).search("POST")
```

### Get one scope by its id

Returns `KeycloakAdmin::ClientAuthzScopeRepresentation`

```ruby 
KeycloakAdmin.realm("a_realm").authz_scopes(client.id).get(scope_id)
```

### Delete one scope

```ruby
KeycloakAdmin.realm("a_realm").authz_scopes(client.id).delete(scope.id)
```

### Create a client authorization resource

note: for scopes, use {name: scope.name} to reference the scope object

Returns added `KeycloakAdmin::ClientAuthzResourceRepresentation`

```ruby 
KeycloakAdmin.realm("realm_id")
        .authz_resources(client.id)
        .create!(
                "Dummy Resource", 
                "type", 
                ["/resource_1/*", "/resource_1/"], 
                true, 
                "display_name", 
                [ {name: scope_1.name} ], 
                {"attribute": ["value_1", "value_2"]}
        )
```

### Update a client authorization resource

Returns updated `KeycloakAdmin::ClientAuthzResourceRepresentation`

note: for scopes, use {name: scope.name} to reference the scope object

```ruby 
KeycloakAdmin.realm("realm_a")
        .authz_resources(client.id)
        .update(resource.id,
                       {
                         "name": "Dummy Resource",
                         "type": "type",
                         "owner_managed_access": true,
                         "display_name": "display_name",
                         "attributes": {"a":["b","c"]},
                         "uris": [ "/resource_1/*" , "/resource_1/" ],
                         "scopes":[
                           {name: scope_1.name},
                           {name: scope_2.name}
                         ],
                         "icon_uri": "https://icon.url"
                       })
```

### Find client authorization resources by (name, type, uri, owner, scope)

Returns array of `KeycloakAdmin::ClientAuthzResourceRepresentation`

```ruby 
KeycloakAdmin.realm("realm_a").authz_resources(client.id).find_by("Dummy Resource", "", "", "", "")
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_resources(client.id).find_by("", "type", "", "", "")
```

### Get client authorization resource by its id

Returns `KeycloakAdmin::ClientAuthzResourceRepresentation`

```ruby 
KeycloakAdmin.realm("realm_a").authz_resources(client.id).get(resource.id)
```

### delete a client authorization resource

```ruby
KeycloakAdmin.realm("realm_a").authz_resources(client.id).delete(resource.id)
```

### Create a client authorization policy

Note: for the moment only `role` policies are supported.

Returns added `KeycloakAdmin::ClientAuthzPolicyRepresentation`

```ruby 
 KeycloakAdmin.realm("realm_a")
        .authz_policies(client.id, 'role')
        .create!("Policy 1", 
                 "description", 
                 "role", 
                 "POSITIVE", 
                 "UNANIMOUS", 
                 true, 
                 [{id: realm_role.id, required: true}]
        )
```

### Find client authorization policies by (name, type)

Returns array of `KeycloakAdmin::ClientAuthzPolicyRepresentation`

```ruby
KeycloakAdmin.realm("realm_a").authz_policies(client.id, 'role').find_by("Policy 1", "role") 
```

### Get client authorization policy by its id

Returns `KeycloakAdmin::ClientAuthzPolicyRepresentation`

```ruby
KeycloakAdmin.realm("realm_a").authz_policies(client.id, 'role').get(policy.id) 
```

### Delete a client authorization policy

```ruby
KeycloakAdmin.realm("realm_a").authz_policies(client.id, 'role').delete(policy.id)
```

### Create a client authorization permission (Resource type)

Returns added `KeycloakAdmin::ClientAuthzPermissionRepresentation`

```ruby 
KeycloakAdmin.realm("realm_a")
        .authz_permissions(client.id, :resource)
        .create!("Dummy Resource Permission", 
                 "resource description", 
                 "UNANIMOUS", 
                 "POSITIVE",
                 [resource.id], 
                 [policy.id],
                 nil, 
                 ""
        )
```

### Create a client authorization permission (Scope type)

Returns added `KeycloakAdmin::ClientAuthzPermissionRepresentation`

```ruby
KeycloakAdmin.realm("realm_a")
        .authz_permissions(client.id, :scope)
        .create!("Dummy Scope Permission", 
                 "scope description", 
                 "UNANIMOUS", 
                 "POSITIVE", 
                 [resource.id], 
                 [policy.id], 
                 [scope_1.id, scope_2.id], 
                 ""
        ) 
```

### List a resource authorization permissions (all: scope or resource)

Return array of `KeycloakAdmin::ClientAuthzPermissionRepresentation`

```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "", resource.id).list
```

### List a resource authorization permissions (by type: resource)

Return array of `KeycloakAdmin::ClientAuthzPermissionRepresentation`

```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, 'resource').list
```
### List a resource authorization permissions (by type: scope)

Return array of `KeycloakAdmin::ClientAuthzPermissionRepresentation`

```ruby 
authz_permissions(client.id, 'scope').list.size
```

### Find client authorization permissions by (name, type, scope)

Return array of `KeycloakAdmin::ClientAuthzPermissionRepresentation`

```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "resource").find_by(resource_permission.name, nil)
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "resource").find_by(resource_permission.name, nil)
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "resource").find_by(resource_permission.name, resource.id)

```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id)
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id, "POST_1")
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "resource").find_by(nil, resource.id)
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "scope").find_by(nil, resource.id)
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "scope").find_by(nil, resource.id, "POST_1")
```
or
```ruby 
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, "scope").find_by(scope_permission.name, nil)
```

### Delete a client authorization permission, scope type

```ruby
KeycloakAdmin.realm("realm_a").authz_permissions(client.id, 'scope').delete(scope.id)
```

### Delete a client authorization permission, resource type

```ruby
 KeycloakAdmin.realm("realm_a").authz_permissions(client.id, 'resource').delete(resource_permission.id)
```

## How to execute library tests

From the `keycloak-admin-api` directory:

```
  $ docker build . -t keycloak-admin:test
  $ docker run -v `pwd`:/usr/src/app/ keycloak-admin:test rspec spec
```
