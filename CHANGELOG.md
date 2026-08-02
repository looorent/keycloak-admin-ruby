# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

* [Fix] `UserClient#update`, `#add_group` and `#remove_group` built their request outside `execute_http`. They were the only methods on this client that raised a bare `Faraday::Error` instead of the documented `KeycloakAdmin::ApiError` hierarchy, and the only ones that did not replay a request rejected on a stale `401`.

## [2.0.2] - 2026-08-01

* [Breaking] HTTP failures now raise a `KeycloakAdmin::ApiError` subclass instead of a bare `RuntimeError`. 
  * Messages are unchanged, so code matching on the text keeps working. 
  * Code rescuing `RuntimeError` explicitly must be updated. 
  * A create call answering something other than `201 Created` now raises `KeycloakAdmin::UnexpectedResponseError`.
* [Feature] A `401` answer now drops the cached access token and replays the request once with a freshly fetched one, so a token revoked before its advertised expiry no longer fails every call until it lapses.
* [Fix] `GroupClient#members` called ActiveSupport's `Object#try` and raised `NoMethodError` outside a Rails application.
* [Fix] `UserClient#execute_actions_email` (and `#forgot_password`) called ActiveSupport's `Numeric#seconds` and raised `NoMethodError` outside a Rails application whenever a `lifespan` was passed.
* [Fix] `ClientAuthzPolicyClient#find_by` opened a second `?` in its URL, which folded `name`, `type`, `first` and `max` into the value of `permission`; Keycloak silently returned an unfiltered list.
* [Fix] Query parameters are now percent-encoded everywhere they are built. Search terms, and the `redirect_uri` of `UserClient#execute_actions_email`, containing a space, `&` or `=` used to break the URL or forge extra parameters.
* [Fix] `OrganizationClient#build` raised `NameError` instead of the intended `ArgumentError` when `domains` was not an `Array`.

## [2.0.1] - 2026-07-31

* [Feature] Requests are now logged through `config.logger` (method, URL, and response status) via Faraday's `:logger` middleware.
* [Feature] The access token is now cached and reused (tracking `expires_in`) instead of being fetched before nearly every call. Previously, caching lived on the `Client` instance, but a fresh `Client` subclass is created for almost every call (e.g. `KeycloakAdmin.realm(x).users` builds a new `UserClient`), so the cache was rarely hit in practice; it now lives on the shared `Configuration`.
* Publish the gem to RubyGems from Github Actions when a `v*` tag is pushed, using RubyGems' Trusted Publishing

## [2.0.0] - 2026-07-31

* [Breaking] Replaced `rest-client` with `Faraday` as the underlying HTTP library. This should be transparent for callers of this gem's own API, but `config.rest_client_options` is renamed to `config.faraday_options` and its shape changes from rest-client's flat hash to Faraday's connection options (e.g. `{ timeout: 5 }` becomes `{ request: { timeout: 5 } }`, `{ verify_ssl: false }` becomes `{ ssl: { verify: false } }`). See the `Configuration` section of the README.
* [Fix] `GroupClient#remove_realm_level_role_name!` used Ruby 3.1 hash value omission
* [Fix] Strip trailing slashes from the configured `server_url`. Keycloak 26 rejects non-normalized request paths with `400 {"error":"missingNormalization"}`, so a `server_url` such as `http://localhost:8080/` produced an unusable `//realms/...` path. Earlier Keycloak versions tolerated it.
* [Chore] `required_ruby_version` is now `>= 3.1` instead of `>= 2.3`
* [Chore] CI now tests against Ruby 3.1, 3.2, 3.3 and 3.4.

## [1.2.0] - 2026-07-30

* [Chore] Bump `http-cookie` dependency from 1.1.0 to 1.1.6.
* [Chore] Upgrade Docker base image from `ruby:3.2.2-slim-bullseye` to `ruby:3.3.12-slim-trixie`.
* [Chore] CI now boots Keycloak 26.7.0 (`quay.io/keycloak/keycloak`) instead of the abandoned `tillawy/keycloak-github-actions:25.0.1`

## [1.1.7] - 2026-03-27

* [Feature] Client scopes - supported operations:  `create!`, `get`, `delete`, `list`, and `search`.
* [Feature] Client scopes protocol mappers - supported operations:  `create!`,  `get`, `delete`, `list`, and `search`.

## [1.1.6] - 2026-01-05

* [Feature] Support for Organizations (Multi-tenancy):
    * **Organization Management**:
        * Supported operations: `create!`, `update`, `get`, `delete`, `list`, and `count`.
        * Supported searching and filtering via `exact`, `query`, and `search` parameters.
    * **Member Management**:
        * Added ability to list organization members with pagination and filtering (`members`).
        * Added `members_count` to retrieve the total number of members.
        * Added `get_member`, `add_member` (by user ID), and `delete_member`.
        * Added helper to find all organizations associated with a specific user: `associated_with_member`.
    * **Invitations**:
        * Added `invite_user`: Invites a new user via email/name.
        * Added `invite_existing_user`: Invites an existing Keycloak user to the organization by ID.
    * **Identity Provider (IdP) Linking**:
        * Added methods to manage IdPs linked to an organization: `identity_providers`, `get_identity_provider`, `add_identity_provider`, and `delete_identity_provider`.

## [1.1.5] - 2026-01-05

* [Feature] Added the ability to list credentials for a given user.
* [Fix] Implemented safe parsing for nested JSON elements within `CredentialRepresentation` (handling both `credentialData` and `secretData` fields). Please refer to [the official documentation](https://www.keycloak.org/docs-api/latest/rest-api/index.html#CredentialRepresentation).
* [Breaking] Renamed `CredentialRepresentation` attribute `created_date` $\rightarrow$ `createdDate` to align with the Keycloak Admin API.

## [1.1.4] - 2025-11-08

* Add remove_realm_level_role_name! action on a GroupClient (thanks to @mkrawc)
* Dependencies: Update Gemfile.lock to bump byebug → 12.0.0, rspec → 3.13.2, and related dependencies
* Bug: The 'remove' operation of the 'RoleMapperClient' does not take the global rest options into account

## [1.1.3] - 2024-07-12

* Client Authorization management support (thanks to @tillawy)
* GitHub-actions setup to execute `rspec` (thanks to @tillawy)

## [1.1.2] - 2024-05-22

* Add group endpoints (get, children, delete), support for group attributes (thanks to @mkrawc)
* GroupClient#save method now can update an existing group (thanks to @mkrawc)
* RoleClient#save method now can update an existing role (thanks to @mkrawc)

## [1.1.1] - 2024-01-21

* Add/List realm-role/s to a group, Allow role-names with spaces, List groups assigned to role (thanks to @LiquidMagical)

## [1.1.0] - 2023-10-03

* Search for groups with parameters (thanks to @@tlloydthwaites)
* Get client by ID, Find client by Client ID, Update Client (thanks to @gee-forr)

## [1.0.24] - 2023-06-07

* Revert the modifications on the feature 'Update a User' introduced in `1.0.22`. This implementation had breaking changes such as not being able to update several attributes (`first_name`, `email`, etc).

## [1.0.23] - 2023-06-01

* Be more permissive about the version of `rest-client` (`~> 2.0`) (thanks to @type-face)

## [1.0.22] - 2023-05-29

* Fetch user's all active sessions (thanks to @prsanjay)
* Check whether a user is locked or not (thanks to @prsanjay)
* Logout users from all the active sessions (thanks to @prsanjay)

## [1.0.21] - 2023-02-03

* List users who are a member of a group (thanks to @tlloydthwaites) 

## [1.0.20] - 2022-12-26

* Create subgroups (thanks to @neckhair)
* Add subgroups to `GroupRepresentation` (thanks to @neckhair)
* Expose `BaseRoleContainingResource.resource_id` (thanks to @neckhair)

## [1.0.19] - 2022-12-03

* Remove specific realm roles from user (thanks to @tlloydthwaites) 
* Get role by name (thanks to @tlloydthwaites) 

## [1.0.18] - 2022-11-24

* List user realm-level role mappings (thanks to @Kazhuu) 

## [1.0.17] - 2022-11-02

* Delete `Client` 

## [1.0.16] - 2022-10-15

* Remove `rest-client` warning when adding a group (thanks to @tlloydthwaites)

## [1.0.15] - 2022-05-23

* Delete all "realm" roles mapped to a user

## [1.0.14] - 2022-03-30

* Update `Gemfile.lock` to avoid wrong CVE detections. The version of Rails should always be specified by the parent project. This change has no functional impact.

## [1.0.13] - 2022-03-13

* Add client role on users
* List client roles

## [1.0.7] - 2022-03-13

* Allow to use multiple `KeycloakAdmin::Client` in the same environment 

## [1.0.6] - 2022-03-13

* When serializing an array to JSON, force the serialization to use `to_json` for each element. In several contexts (e.g. Rails), `to_json` is not used.

## [1.0.5] - 2022-03-11

* Create `Client`
* Create `Identity Provider` (Breaking change: `IdentityProviderRepresentation.configuration` has been renamed to `IdentityProviderRepresentation.config`)
* Add `Identity Provider Mapping`
* Find service account for a `Client`

## [1.0.1] - 2021-10-14

* List all `Identity Providers`
* Add Group on Users (thanks to @tomuench)
* Remove Group from Users (thanks to @tomuench)

## [1.0.0] - 2021-08-03

* Add `totp` on Users
* Add `required_actions` on Users

## [0.7.9] - 2020-10-22

* Extend `search` function to use complex queries (thanks to @hobbypunk90)

## [0.7.8] - 2020-10-15

* Bug: `rest_client_options` default value does not match the documentation (was `nil` by default, should be `{}`)
* Update documentation about client setup (based on Keycloak 11)

## [0.7.7] - 2020-07-10

* Fix: `Replace request method shorthand with .execute for proper RestClient option support` (thanks to @RomanHargrave)
* When sending action emails, add lifespan as an optional parameter (thanks to @hobbypunk90)

## [0.7.6] - 2020-06-22

Thanks to @hobbypunk90 
* Support for action emails and send forgot passsword mail 

## [0.7.5] - 2020-03-28

Thanks to @RomanHargrave
* Support for working with federated identity provider (broker) links

## [0.7.4] - 2019-10-17

* Support for Rails 6

## [0.7.3] - 2019-07-11

Thanks to @cederigo:
* For a given user, get her list of groups

## [0.7.2] - 2019-06-17

Thanks to @vlad-ro:

* Get list of client role mappings for a group
* Save client role mappings for a user/group
* Save realm-level role mappings for a user/group

## [0.7.1] - 2019-06-11

Thanks to @vlad-ro:

* List users
* List clients
* List groups, create/save a group
* List roles, save a role
* List realms, save/update/delete a realm
* Get list of client role mappings for a user
* Support passing rest client options for user save and search
* Support using gem without ActiveSupport

## [0.7.0] - 2019-06-06

Thanks to @vlad-ro:

* Support passing rest client options
* More documentation
* More tests
* Better handling of timeouts

## [0.6.5] - 2019-05-14

* Get user

## [0.6.2] - 2019-05-14

* Update users

## [0.6] - 2019-03-06

* Save a locale when creating a new user

## [0.5] - 2018-01-26

* Client to access Custom REST API configurable-token

## [0.3] - 2018-01-19

* Support of impersonation