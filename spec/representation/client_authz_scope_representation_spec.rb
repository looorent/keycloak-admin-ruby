# frozen_string_literal: true

RSpec.describe KeycloakAdmin::ClientAuthzScopeRepresentation do
  describe '.from_hash' do
    it 'converts json response to class structure' do
      rep = described_class.from_hash({
                                        "id" =>"c0779ce3-0900-4ea3-b1d6-b23e1f19c662",
                                        "name" => "GET",
                                        "iconUri" => "http://asdfasdf/image.png",
                                        "displayName" => "GET authz scope"
                                      })
      expect(rep.id).to eq "c0779ce3-0900-4ea3-b1d6-b23e1f19c662"
      expect(rep.name).to eq "GET"
      expect(rep.icon_uri).to eq "http://asdfasdf/image.png"
      expect(rep.display_name).to eq "GET authz scope"
      expect(rep).to be_a described_class
    end
  end
end