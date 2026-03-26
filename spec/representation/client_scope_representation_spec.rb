# frozen_string_literal: true

RSpec.describe KeycloakAdmin::ClientScopeRepresentation do
  describe ".from_hash" do
    context "with all fields" do
      let(:hash) do
        {
          "id"          => "valid-scope-id",
          "name"        => "my-scope",
          "description" => "A test scope",
          "protocol"    => "openid-connect",
          "attributes"  => {
            "display.on.consent.screen" => "true",
            "include.in.token.scope"    => "true"
          },
          "protocolMappers" => [
            {
              "id"             => "mapper-id",
              "name"           => "my-claim",
              "protocol"       => "openid-connect",
              "protocolMapper" => "oidc-hardcoded-claim-mapper",
              "config"         => { "claim.name" => "my_claim", "claim.value" => "bar" }
            }
          ]
        }
      end

      subject { described_class.from_hash(hash) }

      it "returns an instance of the class" do
        expect(subject).to be_a described_class
      end

      it "sets id" do
        expect(subject.id).to eq "valid-scope-id"
      end

      it "sets name" do
        expect(subject.name).to eq "my-scope"
      end

      it "sets description" do
        expect(subject.description).to eq "A test scope"
      end

      it "sets protocol" do
        expect(subject.protocol).to eq "openid-connect"
      end

      it "sets attributes" do
        expect(subject.attributes).to eq(
          "display.on.consent.screen" => "true",
          "include.in.token.scope"    => "true"
        )
      end

      it "deserializes protocolMappers as ProtocolMapperRepresentation objects" do
        expect(subject.protocol_mappers.size).to eq 1
        expect(subject.protocol_mappers.first).to be_a KeycloakAdmin::ProtocolMapperRepresentation
      end

      it "sets the correct mapper attributes" do
        expect(subject.protocol_mappers.first).to have_attributes(
          id:             "mapper-id",
          name:           "my-claim",
          protocol:       "openid-connect",
          protocolMapper: "oidc-hardcoded-claim-mapper"
        )
      end
    end

    context "without protocolMappers" do
      subject { described_class.from_hash({ "id" => "valid-scope-id", "name" => "my-scope" }) }

      it "defaults protocolMappers to an empty array" do
        expect(subject.protocol_mappers).to eq []
      end
    end

    context "with minimal fields" do
      subject { described_class.from_hash({ "name" => "my-scope", "protocol" => "saml" }) }

      it "sets name" do
        expect(subject.name).to eq "my-scope"
      end

      it "sets protocol" do
        expect(subject.protocol).to eq "saml"
      end

      it "leaves id nil" do
        expect(subject.id).to be_nil
      end

      it "leaves description nil" do
        expect(subject.description).to be_nil
      end

      it "leaves attributes nil" do
        expect(subject.attributes).to be_nil
      end
    end
  end

  describe "#to_json" do
    subject do
      described_class.from_hash(
        "id"          => "valid-scope-id",
        "name"        => "my-scope",
        "description" => "A test scope",
        "protocol"    => "openid-connect",
        "attributes"  => { "include.in.token.scope" => "true" }
      )
    end

    it "serializes to JSON" do
      parsed = JSON.parse(subject.to_json)
      expect(parsed["id"]).to          eq "valid-scope-id"
      expect(parsed["name"]).to        eq "my-scope"
      expect(parsed["description"]).to eq "A test scope"
      expect(parsed["protocol"]).to    eq "openid-connect"
      expect(parsed["attributes"]).to  eq("include.in.token.scope" => "true")
    end
  end
end
