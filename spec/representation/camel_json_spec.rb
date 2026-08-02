# frozen_string_literal: true
RSpec.describe KeycloakAdmin::CamelJson do
  subject(:helper) { Class.new { include KeycloakAdmin::CamelJson }.new }

  describe "#camelize" do
    context "when the first letter must be uppercase" do
      it "camelizes an underscored word" do
        expect(helper.camelize("first_name")).to eq "FirstName"
      end

      it "namespaces a slashed word" do
        expect(helper.camelize("keycloak_admin/user")).to eq "KeycloakAdmin::User"
      end
    end

    context "when the first letter must stay lowercase" do
      it "camelizes an underscored word" do
        expect(helper.camelize("first_name", false)).to eq "firstName"
      end

      it "leaves an already camelized word alone" do
        expect(helper.camelize("userLabel", false)).to eq "userLabel"
      end

      it "handles a single character" do
        expect(helper.camelize("a", false)).to eq "a"
      end

      it "accepts a symbol" do
        expect(helper.camelize(:first_name, false)).to eq "firstName"
      end
    end

    # The lower-case branch used to index the word before checking it, so these raised
    # NoMethodError on nil instead of coming back out as an empty string.
    context "when the word is empty" do
      it "returns an empty string with the first letter in uppercase" do
        expect(helper.camelize("")).to eq ""
      end

      it "returns an empty string with the first letter in lowercase" do
        expect(helper.camelize("", false)).to eq ""
      end

      it "returns an empty string for nil" do
        expect(helper.camelize(nil)).to eq ""
        expect(helper.camelize(nil, false)).to eq ""
      end
    end
  end
end
