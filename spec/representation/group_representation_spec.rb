
RSpec.describe KeycloakAdmin::GroupRepresentation do
  describe ".from_hash" do
    it "parses the sub groups into group representations" do
      group = described_class.from_hash({
        "name" => "group a",
        "attributes" => {
          "key" => ["value"]
        },
        "subGroupCount" => 1,
        "subGroups" => [{
          "name" => "subgroup b"
        }]
      })

      expect(group.attributes).to eq(key: ["value"])
      expect(group.sub_group_count).to eq 1
      expect(group.sub_groups.length).to eq 1
      expect(group.sub_groups.first).to be_a described_class
    end
  end
end
