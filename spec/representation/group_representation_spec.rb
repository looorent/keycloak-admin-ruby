
RSpec.describe KeycloakAdmin::GroupRepresentation do
  describe ".from_hash" do
    it "parses the sub groups into group representations" do
      group = described_class.from_hash({
        "name" => "group a",
        "subGroups" => [{
          "name" => "subgroup b"
        }]
      })
      expect(group.sub_groups.length).to eq 1
      expect(group.sub_groups.first).to be_a described_class
    end
  end
end
