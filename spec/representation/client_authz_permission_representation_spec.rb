RSpec.describe KeycloakAdmin::ClientAuthzPermissionRepresentation do
  describe '.from_hash, #resource based permission' do
    it 'converts json response to class structure' do
      rep = described_class.from_hash({
                                        "id" => "e9e3bc49-fe11-4287-b6fc-fa8be4930ffa",
                                        "resources" => ["4f55e984-d1ec-405c-a25c-1387f88acd5c"],
                                        "policies" => ["e9e3bc49-fe11-4287-b6fc-fa8be4930ffa"],
                                        "name" => "delme policy",
                                        "description" => "Delme policy description",
                                        "decisionStrategy" => "UNANIMOUS",
                                        "resourceType" => ""
                                      })
      expect(rep.id).to eq "e9e3bc49-fe11-4287-b6fc-fa8be4930ffa"
      expect(rep.resources).to eq ["4f55e984-d1ec-405c-a25c-1387f88acd5c"]
      expect(rep.policies).to eq ["e9e3bc49-fe11-4287-b6fc-fa8be4930ffa"]
      expect(rep.name).to eq "delme policy"
      expect(rep.description).to eq "Delme policy description"
      expect(rep.decision_strategy).to eq "UNANIMOUS"
      expect(rep.resource_type).to eq ""
      expect(rep).to be_a described_class
    end
  end

  describe '.from_hash, #scope based permission' do
    it 'converts json response to class structure' do
      rep = described_class.from_hash(

        { "id" => "4d762e5d-bf3d-4641-8f94-97e8a1869d1d",
          "name" => "permission name",
          "description" => "permission description",
          "type" => "scope",
          "policies" => ["e9e3bc49-fe11-4287-b6fc-fa8be4930ffa"],
          "resources" => ["4f55e984-d1ec-405c-a25c-1387f88acd5c"],
          "scopes" => ["7c4809c5-33b6-4668-a318-19b302214d20"],
          "logic" => "POSITIVE",
          "decisionStrategy" => "UNANIMOUS"
        })
      expect(rep.id).to eq "4d762e5d-bf3d-4641-8f94-97e8a1869d1d"
      expect(rep.resources).to eq ["4f55e984-d1ec-405c-a25c-1387f88acd5c"]
      expect(rep.policies).to eq ["e9e3bc49-fe11-4287-b6fc-fa8be4930ffa"]
      expect(rep.scopes).to eq ["7c4809c5-33b6-4668-a318-19b302214d20"]
      expect(rep.name).to eq "permission name"
      expect(rep.description).to eq "permission description"
      expect(rep.decision_strategy).to eq "UNANIMOUS"
      expect(rep.logic).to eq "POSITIVE"
      expect(rep.type).to eq "scope"
      expect(rep.resource_type).to eq nil
      expect(rep).to be_a described_class
    end
  end

end
