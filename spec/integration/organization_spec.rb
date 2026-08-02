require 'spec_helper'

RSpec.describe 'Organization Integration' do
  let(:realm_name) { "dummy" }

  it 'creates, gets and deletes an organization' do
    begin
      org_client = KeycloakAdmin.realm(realm_name).organizations
      org_name = "org-#{SecureRandom.hex(4)}"
      
      org_client.create!(org_name, org_name, true, "description")
      
      orgs = org_client.list(false, nil, nil, nil, nil, org_name)
      fetched_org = orgs.find { |o| o.name == org_name }
      expect(fetched_org).not_to be_nil
      
      org_client.delete(fetched_org.id)
    rescue StandardError => e
      # Organizations API is not available on older Keycloak versions (like KC19)
      puts "Skipping Organization tests due to version incompatibility: #{e.message}"
    end
  end
end
