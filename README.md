
# Keycloak Admin Ruby

Ruby client that acts as a client for the Keycloak REST API.
This gem basically acts as an url builder using `http-client` to get responses and serialize them into _representation_ objects.

_Warning: This beta gem is currently used for personal use. Most Keycloak Admin features are not implemented yet._

## Install

This gem *does not* require Rails.
For example, using `bundle`, add this line to your Gemfile.

```ruby
gem "keycloak-admin", "0.7.5"
```

## Login

You can choose your login process between two different login methods: `username/password` and `Account Service`.

### Login with username/password

Using this login method requires to create a user (and her credentials).
* In Keycloak 
  * Make your client `confidential` or `public`
  * Do not check `Service Accounts Enabled`
* In this gem's configuration
  * Set `use_service_account` to `false`
  * Setup `username` and `password`
  * Setup `client_secret` if your client is `confidential`

### Login with an Account Service

Using a service account to use the REST Admin API does not require to create a dedicated user (http://www.keycloak.org/docs/2.5/server_admin/topics/clients/oidc/service-accounts.html).

* In Keycloak 
  * Make your client `confidential`
  * Check its toggle `Service Accounts Enabled`
  * Disable both `Standard Flow Enabled` and `Implicit Flow Enabled `
  * Enable `Direct Access Grants Enabled`
  * After saving this client, open the `Service Account Roles` and add relevant `realm-management.` client's roles. For instance: `view-users` if you want to search for users using this gem.
* In this gem's configuration
  * Set `use_service_account` to `true`
  * Setup `client_secret`

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
  config.rest_client_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
end
```
This example is autoloaded in a Rails environment.

### Overall configuration options

All options have a default value. However, all of them can be changed in your initializer file.

| Option | Default Value | Type | Required? | Description  | Example |
| ---- | ----- | ------ | ----- | ------ | ----- |
| `server_url` | `nil`| String | Required | The base url where your Keycloak server is located. This value can be retrieved in your Keycloak client configuration. | `server_domain` | `nil`| String | Required | Public domain that identify your authentication cookies. | `auth.service.io` |
| `client_realm_name` | `""`| String | Required | Name of the realm that contains the admin client. | `master` |
| `client_id` | `admin-cli`| String | Required | Client that should be used to access admin capabilities. | `api-cli` |
| `client_secret` | `nil`| String | Optional | If your client is `confidential`, this parameter must be specified. | `4e3c481c-f823-4a6a-b8a7-bf8c86e3eac3` |
| `use_service_account` | `true` | Boolean | Required | `true` if the connection to the client uses a Service Account. `false` if the connection to the client uses a username/password credential. | `false` | 
| `username` | `nil`| String | Optional | Username to access the Admin REST API. Recommended if `user_service_account` is set to `false`. | `mummy` |
| `password` | `nil`| String | Optional | Clear password to access the Admin REST API. Recommended if `user_service_account` is set to `false`. | `bobby` |
| `logger` | `Logger.new(STDOUT)`| Logger | Optional | The logger used by `keycloak-admin` | `Rails.logger` | 
| `rest_client_options` | `{}`| Hash | Optional | Options to pass to `RestClient` | `{ verify_ssl: OpenSSL::SSL::VERIFY_NONE }` | 


## Use Case

### Supported features

* Get an access token
* Create/update/get/delete a user
* Get list of users, search for user(s)
* Reset credentials
* Impersonate a user
* Exchange a configurable token
* Get list of clients
* Get list of groups, create/save a group
* Get list of roles, save a role
* Get list of realms, save/update/delete a realm
* Get list of client role mappings for a user/group
* Save client role mappings for a user/group
* Save realm-level role mappings for a user/group
* Link/Unlink users to federated identity provider brokers

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

```ruby
KeycloakAdmin.realm("a_realm").users.search("a_username_or_an_email")
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
  email: "hello@gmail.com"
})
```

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

Returns an array of `KeycloakAdmin::ClientRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").clients.list
```

### Get list of groups in a realm

Returns an array of `KeycloakAdmin::GroupRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").groups.list
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

## How to execute library tests

From the `keycloak-admin-api` directory:

```
  $ docker build . -t keycloak-admin:test
  $ docker run -v `pwd`:/usr/src/app/ keycloak-admin:test bundle exec rspec spec
```

## Future work

* Allow authentication using JWT assertions
