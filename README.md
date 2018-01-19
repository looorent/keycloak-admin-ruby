
# Keycloak Admin Ruby

Ruby client that acts as a client for the Keycloak REST API.
This gem basically acts as an url builder using `http-client` to get responses and serialize them into _representation_ objects.

_Warning: This beta gem is currently used for personal used. Most Keycloak Admin features are not implemented yet._

## Install

This gem *does not* require Rails.

```ruby
gem "keycloak-admin"
```

## Configuration

To configure this gem, call `KeycloakAdmin.configure`. 
For instance, to configure this gem based on environment variables, write (and load if required) a `keycloak_admin.rb`:
```ruby
KeycloakAdmin.configure do |config|
  config.server_url       = ENV["KEYCLOAK_SERVER_URL"]
  config.client_id        = ENV["KEYCLOAK_ADMIN_CLIENT_ID"]
  config.user_realm_name  = ENV["KEYCLOAK_REALM_ID"]
  config.username         = ENV["KEYCLOAK_ADMIN_USER"]
  config.password         = ENV["KEYCLOAK_ADMIN_PASSWORD"]
  config.logger           = Rails.logger
end
```
This example is autoloaded in a Rails environment.

### Overall configuration options

All options have a default value. However, all of them can be changed in your initializer file.

| Option | Default Value | Type | Required? | Description  | Example |
| ---- | ----- | ------ | ----- | ------ | ----- |
| `server_url` | `nil`| String | Required | The base url where your Keycloak server is located. This value can be retrieved in your Keycloak client configuration. | `auth:8080/auth` |
| `user_realm_name` | `""`| String | Required | Name of the realm that contain the admin client and user. | `master` |
| `client_id` | `admin-cli`| String | Required | Client that should be used to access admin capabilities. | `api-cli` |
| `username` | `nil`| String | Required | Username that access to the Admin REST API | `mummy` |
| `password` | `nil`| String | Required | Clear password that access to the Admin REST API | `bobby` |
| `logger` | `Logger.new(STDOUT)`| Logger | Optional | The logger used by `keycloak-admin` | `Rails.logger` | 


## Use Case
exit
### Supported features

* Get an access token
* Create a user
* Reset credentials
* Delete a user

### Get an access token

Returns an instance of `KeycloakAdmin::TokenRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").token.get
```

### Search for users

Returns an array of `KeycloakAdmin::UserRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").users.search("a_username_or_an_email")
```

### Save a user

Returns the provided `user`, which must be of type `KeycloakAdmin::UserRepresentation`.

```ruby
KeycloakAdmin.realm("a_realm").users.save(user)
```

### Create and save a user with password

Returns the created user of type `KeycloakAdmin::UserRepresentation`.

```ruby
username       = "pioupioux"
email          = "pioupioux@email.com"
password       = "acme0"
email_verified = true
KeycloakAdmin.realm("a_realm").users.create!(username, email, password, email_verified)
```

### Reset a password

```ruby
user_id      = "95985b21-d884-4bbd-b852-cb8cd365afc2"
new_password = "coco"
KeycloakAdmin.realm("commuty").users.update_password(user_id, new_password)
```

## How to execute library tests

From the `keycloak-admin-api` directory:

```
  $ docker build . -t keycloak-admin:test
  $ docker run -v `pwd`:/usr/src/app/ keycloak-admin:test bundle exec rspec spec
```
