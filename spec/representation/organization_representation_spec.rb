
RSpec.describe KeycloakAdmin::OrganizationRepresentation do
  describe ".from_json" do
    it "parse a single organization" do
      json_payload = <<-'payload'
        {
          "id": "8f6e474e-e688-4bec-99ba-5dc862594f4b",
          "name": "My organization",
          "alias": "myorg",
          "enabled": true,
          "description": "A single organization",
          "redirectUrl": "https://myapp.acme.com",
          "attributes": {
              "advanced": [
                  "yes"
              ],
              "days": [
                "monday",
                "friday"
              ]
          },
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

      organization = described_class.from_json(json_payload)
      expect(organization).to be
      expect(organization).to be_a described_class
      expect(organization.id).to eq "8f6e474e-e688-4bec-99ba-5dc862594f4b"
      expect(organization.name).to eq "My organization"
      expect(organization.alias).to eq "myorg"
      expect(organization.description).to eq "A single organization"
      expect(organization.redirect_url).to eq "https://myapp.acme.com"
      expect(organization.enabled).to be true
      
      expect(organization.domains.size).to eq 2
      expect(organization.domains[0]).to be_a KeycloakAdmin::OrganizationDomainRepresentation
      expect(organization.domains[0].name).to eq "hello.com"
      expect(organization.domains[0].verified).to be false
      expect(organization.domains[1]).to be_a KeycloakAdmin::OrganizationDomainRepresentation
      expect(organization.domains[1].name).to eq "gmail.com"
      expect(organization.domains[1].verified).to be true

      expect(organization.attributes.size).to eq 2
      expect(organization.attributes["advanced"].size).to eq 1
      expect(organization.attributes["advanced"][0]).to eq "yes"
      expect(organization.attributes["days"].size).to eq 2
      expect(organization.attributes["days"][0]).to eq "monday"
      expect(organization.attributes["days"][1]).to eq "friday"

      expect(organization.members.size).to eq 0
      expect(organization.identity_providers.size).to eq 0
    end
  end
end
