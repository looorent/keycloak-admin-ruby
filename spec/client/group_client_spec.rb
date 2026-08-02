RSpec.describe KeycloakAdmin::GroupClient do
  describe "#groups_url" do
    let(:realm_name) { "valid-realm" }
    let(:group_id)    { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).groups.groups_url(group_id)
    end

    context "when group_id is not defined" do
      let(:group_id) { nil }
      it "return a proper url without group id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/groups"
      end
    end

    context "when group_id is defined" do
      let(:group_id) { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "return a proper url with the group id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/groups/95985b21-d884-4bbd-b852-cb8cd365afc2"
      end
    end
  end

  describe "#get" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:get, "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id").to_return(body: '{"id":"test_group_id","name":"test_group_name"}')
    end

    it "get a group" do
      group = @group_client.get("test_group_id")
      expect(group.id).to eq "test_group_id"
      expect(group.name).to eq "test_group_name"
    end

    it "passes rest client options" do
      faraday_options = {request: {timeout: 10}}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id", faraday_options, anything).and_call_original

      group = @group_client.get("test_group_id")
      expect(group.id).to eq "test_group_id"
      expect(group.name).to eq "test_group_name"
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:get, "http://auth.service.io/auth/admin/realms/valid-realm/groups").to_return(body: '[{"id":"test_group_id","name":"test_group_name"}]')
    end

    it "lists groups" do
      groups = @group_client.list
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end

    it "passes rest client options" do
      faraday_options = {request: {timeout: 10}}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups", faraday_options, anything).and_call_original

      groups = @group_client.list
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end
  end


  describe "#children" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:get, "http://auth.service.io/auth/admin/realms/valid-realm/groups/parent_group_id/children").to_return(body: '[{"id":"test_group_id","name":"test_group_name"}]')
    end

    it "lists children groups" do
      groups = @group_client.children("parent_group_id")
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end

    it "passes rest client options" do
      faraday_options = {request: {timeout: 10}}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups/parent_group_id/children", faraday_options, anything).and_call_original

      groups = @group_client.children("parent_group_id")
      expect(groups.length).to eq 1
      expect(groups[0].name).to eq "test_group_name"
    end
  end

  describe "#save" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
    end

    context "when the group does not exist" do
      let(:group) { KeycloakAdmin::GroupRepresentation.from_hash(
        "name" => "test_group_name"
      )}

      before do
        stub_request(:post, "http://auth.service.io/auth/admin/realms/valid-realm/groups").with(body: group.to_json).to_return(headers: { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b' }, status: 201)
      end

      it "saves a group" do
        @group_client.save(group)
      end

      it "passes rest client options" do
        faraday_options = {request: {timeout: 10}}
        allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

        expect(KeycloakAdmin::Resource).to receive(:new).with(
          "http://auth.service.io/auth/admin/realms/valid-realm/groups", faraday_options, anything).and_call_original

        @group_client.save(group)
      end
    end

    context "when the group already exists" do
      let(:group) { KeycloakAdmin::GroupRepresentation.from_hash(
        "id" => "test_group_id",
        "name" => "test_group_name"
      )}

      before do
        stub_request(:put, "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id").with(body: group.to_json).to_return(headers: { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b' }, status: 200)
      end

      it "saves a group" do
        @group_client.save(group)
      end

      it "passes rest client options" do
        faraday_options = {request: {timeout: 10}}
        allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

        expect(KeycloakAdmin::Resource).to receive(:new).with(
          "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id", faraday_options, anything).and_call_original

        @group_client.save(group)
      end
    end
  end

  describe "#create" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:post, "http://auth.service.io/auth/admin/realms/valid-realm/groups").to_return(
        headers: { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b' },
        status: [201, 'Created']
      )
    end

    it "creates a group" do
      group_id = @group_client.create!("test_group_name")
      expect(group_id).to eq 'be061c48-6edd-4783-a726-1a57d4bfa22b'
    end

    it "detects unexpected response to create a group" do
      stub_request(:post, "http://auth.service.io/auth/admin/realms/valid-realm/groups").to_return(status: [200, 'OK'])

      expect{ @group_client.create!("test_group_name") }.to raise_error(
        'Create method returned status OK (Code: 200); expected status: Created (201)'
      )
    end
  end

  describe "#create_subgroup!" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:post, "http://auth.service.io/auth/admin/realms/valid-realm/groups/be061c48-6edd-4783-a726-1a57d4bfa22b/children").to_return(
        headers: { location: 'http://auth.service.io/auth/admin/realms/valid-realm/groups/7686af34-204c-4515-8122-78d19febbf6e' },
        status: [201, 'Created']
      )
    end

    it "creates a subgroup" do
      group_id = @group_client.create_subgroup!('be061c48-6edd-4783-a726-1a57d4bfa22b', 'subgroup-name')
      expect(group_id).to eq '7686af34-204c-4515-8122-78d19febbf6e'
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:delete, "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id").to_return(body: '')
    end

    it "deletes a group" do
      result = @group_client.delete("test_group_id")
      expect(result).to be(true)
    end

    it "raises a delete error" do
      faraday_options = {request: {timeout: 10}}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:faraday_options).and_return faraday_options

      expect(KeycloakAdmin::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/groups/test_group_id", faraday_options, anything).and_raise("error")

      expect { @group_client.delete("test_group_id") }.to raise_error("error")
    end
  end

  describe '#get_realm_level_roles' do
    let(:realm_name) { 'valid-realm' }
    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups
      stub_token_client
      stub_request(:get, "http://auth.service.io/auth/admin/realms/valid-realm/groups/test-group-id/role-mappings/realm").to_return(body: '[{"id":"role-id","name":"role-name"}]')
    end

    it 'gets all realm-level roles for a group' do
      roles = @group_client.get_realm_level_roles('test-group-id')
      expect(roles.length).to eq 1
      expect(roles[0].id).to eq 'role-id'
      expect(roles[0].name).to eq 'role-name'
    end
  end

  describe '#add_realm_level_role_name!' do
    let(:realm_name) { 'valid-realm' }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:post, "http://auth.service.io/auth/admin/realms/valid-realm/groups/test-group-id/role-mappings/realm").to_return(body: '')
    end

    it 'adds a realm-level role to a group' do
      role_representation = double
      allow(role_representation).to receive(:name).and_return 'test-role-name'

      role_client = double
      allow(role_client).to receive(:get).with('test-role-name').and_return role_representation
      allow(KeycloakAdmin::RoleClient).to receive(:new).and_return role_client

      result = @group_client.add_realm_level_role_name!('test-group-id', 'test-role-name')
      expect(result).to eq role_representation
    end
  end

  describe '#remove_realm_level_role_name!' do
    let(:realm_name) { 'valid-realm' }

    before(:each) do
      @group_client = KeycloakAdmin.realm(realm_name).groups

      stub_token_client
      stub_request(:delete, "http://auth.service.io/auth/admin/realms/valid-realm/groups/test-group-id/role-mappings/realm").to_return(body: '')
    end

    it 'deletes a realm-level role from a group' do
      role_representation = double
      allow(role_representation).to receive(:name).and_return 'test-role-name'

      role_client = double
      allow(role_client).to receive(:get).with('test-role-name').and_return role_representation
      allow(KeycloakAdmin::RoleClient).to receive(:new).and_return role_client

      result = @group_client.remove_realm_level_role_name!('test-group-id', 'test-role-name')
      expect(result).to be(true)
      expect(a_request(:delete, "http://auth.service.io/auth/admin/realms/valid-realm/groups/test-group-id/role-mappings/realm").with(
        body: @group_client.send(:create_payload, [role_representation])
      )).to have_been_made.once
    end
  end
end

RSpec.describe "KeycloakAdmin::GroupClient#members" do
  let(:realm_name) { "valid-realm" }
  let(:group_id)   { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
  let(:base_url)   { "http://auth.service.io/auth/admin/realms/valid-realm/groups/#{group_id}/members" }

  before(:each) { stub_token_client }

  it "paginates with the default bounds" do
    request = stub_request(:get, base_url).with(query: {"first" => "0", "max" => "100"}).to_return(body: "[]")

    KeycloakAdmin.realm(realm_name).groups.members(group_id)

    expect(request).to have_been_requested
  end

  # Regression: this used ActiveSupport's Object#try, which raised NoMethodError outside Rails.
  it "coerces the bounds to integers without depending on ActiveSupport" do
    request = stub_request(:get, base_url).with(query: {"first" => "5", "max" => "20"}).to_return(body: "[]")

    KeycloakAdmin.realm(realm_name).groups.members(group_id, "5", "20")

    expect(request).to have_been_requested
  end

  it "omits the query string entirely when both bounds are nil" do
    requested_uri = nil
    stub_request(:get, /members/).with { |request| requested_uri = request.uri.to_s; true }.to_return(body: "[]")

    KeycloakAdmin.realm(realm_name).groups.members(group_id, nil, nil)

    expect(requested_uri).to_not include "?"
    expect(requested_uri).to end_with "/groups/#{group_id}/members"
  end

  it "maps the response onto UserRepresentations" do
    stub_request(:get, base_url).with(query: hash_including({}))
      .to_return(body: '[{"id":"u1","username":"alice"}]')

    members = KeycloakAdmin.realm(realm_name).groups.members(group_id)

    expect(members.map(&:username)).to eq ["alice"]
  end
end
