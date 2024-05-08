# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2024-03-11

* Be more permissive with user attributes on create/update
* Camelize user params on update
* Return user object on update (same as create)
* Add activesupport to enable deep camelize of JSON objects
* Let exceptions move up the call stack

## [1.1.1] - 2024-01-21

* Add/List realm-role/s to a group, Allow role-names with spaces, List groups assigned to role (thanks to @LiquidMagical
)

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