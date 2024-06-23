RSpec.describe KeycloakAdmin::ClientAuthzResourceRepresentation do
  describe '.from_hash' do
    it 'converts json response to class structure' do
      rep = described_class.from_hash({
                                        "name" => "Default Resource",
                                        "type" => "urn:delme-client-id:resources:default",
                                        "owner" => {
                                          "id" => "d259b451-371b-432a-a526-3508f3a36f3b",
                                          "name" => "delme-client-id"
                                        },
                                        "ownerManagedAccess" => true,
                                        "displayName" => "Display Name",
                                        "attributes" => { "a" => ["b"]},
                                        "_id" => "385966a2-14b9-4cc4-9539-5f2fe1008222",
                                        "uris" => ["/*"],
                                        "scopes" => [{"id"=>"c0779ce3-0900-4ea3-b1d6-b23e1f19c662",
                                                    "name" => "GET",
                                                    "iconUri" => "http=>//asdfasdf"}],
                                        "icon_uri" => "http://icon"
                                      })
      expect(rep.id).to eq "385966a2-14b9-4cc4-9539-5f2fe1008222"
      expect(rep.name).to eq "Default Resource"
      expect(rep.type).to eq "urn:delme-client-id:resources:default"
      expect(rep.uris).to eq ["/*"]
      expect(rep.owner_managed_access).to eq true
      expect(rep.attributes).to eq({ :"a" => ["b"]})
      expect(rep.display_name).to eq "Display Name"
      expect(rep.scopes[0].id).to eq "c0779ce3-0900-4ea3-b1d6-b23e1f19c662"
      expect(rep.scopes[0].name).to eq "GET"
      expect(rep).to be_a described_class
    end
  end
end
