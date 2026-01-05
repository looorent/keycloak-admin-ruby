RSpec.describe KeycloakAdmin::OrganizationClient do
  describe "#organization_url" do
    let(:realm_name)       { "valid-realm" }
    let(:organization_id)  { nil }

    before(:each) do
      @built_url = KeycloakAdmin.realm(realm_name).organizations.organization_url(organization_id)
    end

    context "when organization_id is defined" do
      let(:organization_id) { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "return a proper url with the organization id" do
        expect(@built_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/organizations/95985b21-d884-4bbd-b852-cb8cd365afc2"
      end
    end
  end

  describe "#list" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      json_payload = <<-'payload'
        [
          {
            "id": "8f6e474e-e688-4bec-99ba-5dc862594f4b",
            "name": "My organization",
            "alias": "myorg",
            "enabled": true,
            "description": "A single organization",
            "domains": [
              {
                "name": "hello.com",
                "verified": false
              },
              {
                "name": "gmail.com",
                "verified": true
              }
            ]
          }
        ]
      payload
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "lists organizations" do
      organizations = @organization_client.list
      expect(organizations.length).to eq 1
      expect(organizations[0].id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
      expect(organizations[0].name).to eq "My organization"
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/organizations?briefRepresentation=true", rest_client_options).and_call_original

      organizations = @organization_client.list
      expect(organizations.length).to eq 1
      expect(organizations[0]).to be_a KeycloakAdmin::OrganizationRepresentation
      expect(organizations[0].id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
      expect(organizations[0].name).to eq "My organization"
    end
  end

  describe "#count" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      json_payload = "2"
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "count organizations" do
      count = @organization_client.count(false, nil, "test")
      expect(count).to eq 2
    end

    context "when building the count url" do
      let(:exact)  { nil }
      let(:query)  { nil }
      let(:search) { nil }

      before(:each) do
        @count_url = @organization_client.count_url(exact, query, search)
      end

      context "with everything null" do
        it "return a proper url" do
          expect(@count_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/organizations/count?"
        end 
      end

      context "with exact=false" do
        let(:exact)  { false }
        it "return a proper url" do
          expect(@count_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/organizations/count?exact=false"
        end 
      end

      context "with exact=true" do
        let(:exact)  { true }
        it "return a proper url" do
          expect(@count_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/organizations/count?exact=true"
        end 
      end

      context "with query=test" do
        let(:query)  { "test" }
        it "return a proper url" do
          expect(@count_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/organizations/count?q=test"
        end 
      end

      context "with search=nameoforg" do
        let(:search) { "nameoforg" }
        it "return a proper url" do
          expect(@count_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/organizations/count?search=nameoforg"
        end 
      end

      context "with every argument setup" do
        let(:exact)  { true }
        let(:query)  { "a query" }
        let(:search) { "a name" }
        it "return a proper url" do
          expect(@count_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/organizations/count?exact=true&q=a query&search=a name"
        end 
      end
    end
  end

  describe "#associated_with_member" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      json_payload = <<-'payload'
        [
          {
            "id": "8f6e474e-e688-4bec-99ba-5dc862594f4b",
            "name": "My organization",
            "alias": "myorg",
            "enabled": true,
            "description": "A single organization",
            "domains": [
              {
                "name": "hello.com",
                "verified": false
              },
              {
                "name": "gmail.com",
                "verified": true
              }
            ]
          }
        ]
      payload
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "list organizations of members organizations" do
      organizations = @organization_client.associated_with_member("648ebe7f-e4ba-4d82-a87d-c585c866d0e7")
      expect(organizations.size).to eq 1
      expect(organizations[0]).to be_a KeycloakAdmin::OrganizationRepresentation
      expect(organizations[0].id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
    end
  end

  describe "#delete" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return ""
    end

    it "deletes an organization" do
      result = @organization_client.delete("2904e1a1-e5f4-4143-8725-003e54cc8b58")
      expect(result).to be(true)
    end

    it "raises a delete error" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/organizations/2904e1a1-e5f4-4143-8725-003e54cc8b58", rest_client_options).and_raise("error")

      expect { @organization_client.delete("2904e1a1-e5f4-4143-8725-003e54cc8b58") }.to raise_error("error")
    end
  end

  describe "#identity_providers" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      json_payload = <<-'payload'
        [
          {
            "alias": "google",
            "displayName": "",
            "internalId": "59b28b03-07db-4281-b637-4040368df082",
            "providerId": "google",
            "enabled": true,
            "updateProfileFirstLoginMode": "on",
            "trustEmail": false,
            "storeToken": false,
            "addReadTokenRoleOnCreate": false,
            "authenticateByDefault": false,
            "linkOnly": false,
            "hideOnLogin": true,
            "organizationId": "8f6e474e-e688-4bec-99ba-5dc862594f4b",
            "config": {
              "syncMode": "LEGACY",
              "clientSecret": "**********",
              "clientId": "test",
              "kc.org.broker.redirect.mode.email-matches": "false"
            }
          }
        ]
      payload
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "get identity providers" do
      identity_providers = @organization_client.identity_providers("8f6e474e-e688-4bec-99ba-5dc862594f4b")
      expect(identity_providers.size).to eq 1
      expect(identity_providers[0]).to be_a KeycloakAdmin::IdentityProviderRepresentation
      expect(identity_providers[0].alias).to eq "google"
      expect(identity_providers[0].organization_id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
    end
  end

  describe "#add_identity_provider" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return ""
    end

    it "adds one identity provider" do
      @organization_client.add_identity_provider("8f6e474e-e688-4bec-99ba-5dc862594f4b", "google")
    end
  end

  describe "#get_identity_provider" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      json_payload = <<-'payload'
        {
          "alias": "google",
          "displayName": "",
          "internalId": "59b28b03-07db-4281-b637-4040368df082",
          "providerId": "google",
          "enabled": true,
          "updateProfileFirstLoginMode": "on",
          "trustEmail": false,
          "storeToken": false,
          "addReadTokenRoleOnCreate": false,
          "authenticateByDefault": false,
          "linkOnly": false,
          "hideOnLogin": true,
          "organizationId": "8f6e474e-e688-4bec-99ba-5dc862594f4b",
          "config": {
            "syncMode": "LEGACY",
            "clientSecret": "**********",
            "clientId": "test",
            "kc.org.broker.redirect.mode.email-matches": "false"
          }
        }
      payload
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "get identity provider" do
      idp = @organization_client.get_identity_provider("8f6e474e-e688-4bec-99ba-5dc862594f4b", "google")
      expect(idp).to be_a KeycloakAdmin::IdentityProviderRepresentation
      expect(idp.alias).to eq "google"
    end
  end

  describe "#get" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      json_payload = <<-'payload'
        {
          "id": "8f6e474e-e688-4bec-99ba-5dc862594f4b",
          "name": "My organization",
          "alias": "myorg",
          "enabled": true,
          "description": "A single organization",
          "domains": [
            {
              "name": "hello.com",
              "verified": false
            },
            {
              "name": "gmail.com",
              "verified": true
            }
          ]
        }
      payload
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "get organization" do
      organization = @organization_client.get("8f6e474e-e688-4bec-99ba-5dc862594f4b")
      expect(organization).to be
      expect(organization).to be_a KeycloakAdmin::OrganizationRepresentation
      expect(organization.id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
      expect(organization.name).to eq "My organization"
    end

    it "passes rest client options" do
      rest_client_options = {timeout: 10}
      allow_any_instance_of(KeycloakAdmin::Configuration).to receive(:rest_client_options).and_return rest_client_options

      expect(RestClient::Resource).to receive(:new).with(
        "http://auth.service.io/auth/admin/realms/valid-realm/organizations/8f6e474e-e688-4bec-99ba-5dc862594f4b", rest_client_options).and_call_original

      organization = @organization_client.get("8f6e474e-e688-4bec-99ba-5dc862594f4b")
      expect(organization).to be
      expect(organization).to be_a KeycloakAdmin::OrganizationRepresentation
      expect(organization.id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
    end
  end

  describe "#members_count" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return "2"
    end

    it "get count of members" do
      count = @organization_client.members_count("8f6e474e-e688-4bec-99ba-5dc862594f4b")
      expect(count).to eq 2
    end
  end

  describe "#members" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      json_payload = <<-'payload'
        [
          {
              "id": "648ebe7f-e4ba-4d82-a87d-c585c866d0e7",
              "username": "admin",
              "emailVerified": false,
              "attributes": {
                  "is_temporary_admin": [
                      "true"
                  ]
              },
              "enabled": true,
              "createdTimestamp": 1767600090489,
              "totp": false,
              "disableableCredentialTypes": [],
              "requiredActions": [],
              "notBefore": 0,
              "membershipType": "UNMANAGED"
          },
          {
              "id": "2167481a-6a08-44f3-aa9a-42e33afa6834",
              "username": "client",
              "emailVerified": true,
              "enabled": true,
              "createdTimestamp": 1767601626861,
              "totp": false,
              "disableableCredentialTypes": [],
              "requiredActions": [],
              "notBefore": 0,
              "membershipType": "MANAGED"
          }
      ]
      payload
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "get members" do
      members = @organization_client.members("8f6e474e-e688-4bec-99ba-5dc862594f4b")
      expect(members.size).to eq 2
      expect(members[0]).to be_a KeycloakAdmin::MemberRepresentation
      expect(members[0].id).to eq "648ebe7f-e4ba-4d82-a87d-c585c866d0e7"
      expect(members[0].membership_type).to eq "UNMANAGED"
      expect(members[1]).to be_a KeycloakAdmin::MemberRepresentation
      expect(members[1].id).to eq "2167481a-6a08-44f3-aa9a-42e33afa6834"
      expect(members[1].membership_type).to eq "MANAGED"
    end
  end

  describe "#invite_existing_user" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return ""
    end

    it "invites an existing user" do
      @organization_client.invite_existing_user("8f6e474e-e688-4bec-99ba-5dc862594f4b", "9a2ff47d-759c-4126-a281-8e4a7c6465e4")
    end
  end

  describe "#invite_user" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return ""
    end

    it "invites an existing user" do
      @organization_client.invite_user("8f6e474e-e688-4bec-99ba-5dc862594f4b", "hello@acme.com", "John", "Doe")
    end
  end

  describe "#delete_member" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete).and_return ""
    end

    it "deletes a member" do
      result = @organization_client.delete_member("8f6e474e-e688-4bec-99ba-5dc862594f4b", "e226d9d3-868e-453b-9bfc-d9d9cc534526")
      expect(result).to be(true)
    end
  end

  describe "#get_member" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      json_payload = <<-'payload'
        {
          "id": "9a2ff47d-759c-4126-a281-8e4a7c6465e4",
          "username": "hello",
          "email": "hello@gmail.com",
          "emailVerified": true,
          "enabled": true,
          "createdTimestamp": 1767608088024,
          "totp": false,
          "disableableCredentialTypes": [],
          "requiredActions": [],
          "notBefore": 0,
          "membershipType": "UNMANAGED"
        }  
      payload
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "gets a member" do
      member = @organization_client.get_member("8f6e474e-e688-4bec-99ba-5dc862594f4b", "9a2ff47d-759c-4126-a281-8e4a7c6465e4")
      expect(member).to be
      expect(member).to be_a KeycloakAdmin::MemberRepresentation
      expect(member.id).to eq "9a2ff47d-759c-4126-a281-8e4a7c6465e4"
      expect(member.membership_type).to eq "UNMANAGED"
    end
  end

  describe "#add_member" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return ""
    end

    it "creates a member from an existing user" do
      result = @organization_client.add_member("8f6e474e-e688-4bec-99ba-5dc862594f4b", "9a2ff47d-759c-4126-a281-8e4a7c6465e4")
      expect(result).to be true
    end
  end

  describe "#add_member" do
    let(:realm_name) { "valid-realm" }

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return ""
    end

    it "creates a member from an existing user" do
      result = @organization_client.add_member("8f6e474e-e688-4bec-99ba-5dc862594f4b", "9a2ff47d-759c-4126-a281-8e4a7c6465e4")
      expect(result).to be true
    end
  end

  describe "#update" do
    let(:realm_name) { "valid-realm" }
    let(:json_payload) do
      <<-'payload'
        {
          "id": "8f6e474e-e688-4bec-99ba-5dc862594f4b",
          "name": "Company",
          "alias": "company",
          "enabled": true,
          "description": "A test organization",
          "redirectUrl": "https://myapp.acme.com/redirect",
          "attributes": {
              "hello": [
                  "yes"
              ]
          },
          "domains": [
              {
                  "name": "hello.com",
                  "verified": false
              },
              {
                  "name": "help.com",
                  "verified": false
              }
          ]
      }  
      payload
    end

    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:put).and_return ""
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return json_payload
    end

    it "updates an organization" do
      organization         = KeycloakAdmin::OrganizationRepresentation.from_json(json_payload)
      updated_organization = @organization_client.update(organization)
      expect(updated_organization).to be
      expect(updated_organization).to be_a KeycloakAdmin::OrganizationRepresentation
      expect(updated_organization.id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
    end
  end

  describe "#create!" do
    let(:realm_name) { "valid-realm" }
    before(:each) do
      @organization_client = KeycloakAdmin.realm(realm_name).organizations
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:post).and_return ""
    end

    it "creates an organization" do
      @organization_client.create!(
        "new name",
        "alias_name",
        "enabled",
        "description",
        "http://redirect_url",
        [
          KeycloakAdmin::OrganizationDomainRepresentation.new("acme.com", true),
          KeycloakAdmin::OrganizationDomainRepresentation.new("doe.com", false)
        ],
        {
          "advanced": ["yes", "no"],
          "hello": ["maybe"]
        }
      )
    end
  end
end
