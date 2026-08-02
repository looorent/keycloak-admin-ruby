# frozen_string_literal: true
require_relative '../integration_helper'
require 'securerandom'

# Seeds more users than Keycloak returns by default, so the server-side cap is exercised for
# real rather than asserted from documentation. Runs in a realm of its own: the shared `dummy`
# realm is asserted on by the other integration specs, and a hundred extra users would break them.
RSpec.describe 'Pagination Integration' do
  # Keycloak answers GET /users with at most Constants.DEFAULT_MAX_RESULTS entries when `max`
  # is absent. Verified identical on Keycloak 19.0, 23.0 and 26.7.0.
  SERVER_DEFAULT_MAX = 100
  USER_COUNT         = SERVER_DEFAULT_MAX + 5
  GROUP_COUNT        = 12

  let(:realm_name) { "pagination-realm-#{SecureRandom.hex(4)}" }

  around(:each) do |example|
    realms_client = KeycloakAdmin::RealmClient.new(KeycloakAdmin.config, nil)
    realms_client.save(
      KeycloakAdmin::RealmRepresentation.from_hash({"realm" => realm_name, "enabled" => true})
    )
    begin
      example.run
    ensure
      KeycloakAdmin.realm(realm_name).delete
    end
  end

  describe 'users.list' do
    before(:each) do
      users = KeycloakAdmin.realm(realm_name).users
      USER_COUNT.times do |index|
        users.save(
          KeycloakAdmin::UserRepresentation.from_hash(
            "username" => format("paginated-user-%03d", index), "enabled" => true
          )
        )
      end
    end

    it 'is truncated by the server default when no bound is given' do
      expect(KeycloakAdmin.realm(realm_name).users.list.size).to eq SERVER_DEFAULT_MAX
    end

    it 'returns every user when max is raised above the server default' do
      expect(KeycloakAdmin.realm(realm_name).users.list(max: USER_COUNT * 2).size).to eq USER_COUNT
    end

    it 'skips the first entries when first is given' do
      expect(KeycloakAdmin.realm(realm_name).users.list(first: SERVER_DEFAULT_MAX, max: USER_COUNT * 2).size)
        .to eq(USER_COUNT - SERVER_DEFAULT_MAX)
    end

    it 'walks the whole realm in disjoint pages' do
      page_size = 40
      pages     = (0...USER_COUNT).step(page_size).map do |offset|
        KeycloakAdmin.realm(realm_name).users.list(first: offset, max: page_size).map(&:username)
      end

      expect(pages.flatten.uniq.size).to eq USER_COUNT
      expect(pages.first.size).to eq page_size
    end
  end

  describe 'groups.list' do
    before(:each) do
      groups = KeycloakAdmin.realm(realm_name).groups
      GROUP_COUNT.times { |index| groups.create!(format("paginated-group-%03d", index)) }
    end

    # Unlike users, this endpoint applies no default cap: bounds are honoured but a bare list
    # already returns everything. Verified on Keycloak 19.0, 23.0 and 26.7.0.
    it 'returns every group when no bound is given' do
      expect(KeycloakAdmin.realm(realm_name).groups.list.size).to eq GROUP_COUNT
    end

    it 'caps the answer at max' do
      expect(KeycloakAdmin.realm(realm_name).groups.list(max: 5).size).to eq 5
    end

    it 'walks the whole realm in disjoint pages' do
      first_page  = KeycloakAdmin.realm(realm_name).groups.list(first: 0, max: 5).map(&:name)
      second_page = KeycloakAdmin.realm(realm_name).groups.list(first: 5, max: 5).map(&:name)

      expect(first_page.size).to eq 5
      expect(second_page.size).to eq 5
      expect(first_page & second_page).to be_empty
    end
  end
end
