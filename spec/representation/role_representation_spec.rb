# frozen_string_literal: true
RSpec.describe KeycloakAdmin::RoleRepresentation do
  describe "accessors" do
    it "does not define spurious accessors from a trailing comma" do
      expect(described_class.instance_methods(false)).not_to include(:from_hash, :from_hash=)
    end
  end

  describe "#to_json" do
    before(:each) do
      @mapper = KeycloakAdmin::RoleRepresentation.from_hash(
        {
          "id" => "bb79fb10-a7b4-4728-a662-82a4de7844a3",
          "name" => "abcd",
          "composite" => true,
          "clientRole" => false
        }
      )
    end

    it "can convert to json" do
      expect(@mapper.to_json).to eq "{\"id\":\"bb79fb10-a7b4-4728-a662-82a4de7844a3\",\"name\":\"abcd\",\"composite\":true,\"clientRole\":false}"
    end
  end

  describe "array#to_json" do
    before(:each) do
      @mappers = [
        KeycloakAdmin::RoleRepresentation.from_hash(
          {
            "id" => "bb79fb10-a7b4-4728-a662-82a4de7844a3",
            "name" => "abcd",
            "composite" => true,
            "clientRole" => false
          }
        )
      ]
    end

    it "can convert to json" do
      expect(@mappers.to_json).to eq "[{\"id\":\"bb79fb10-a7b4-4728-a662-82a4de7844a3\",\"name\":\"abcd\",\"composite\":true,\"clientRole\":false}]"
    end
  end
end
