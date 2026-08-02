# frozen_string_literal: true
RSpec.describe "keycloak-admin.gemspec" do
  let(:gemspec_path) { File.expand_path("../keycloak-admin.gemspec", __dir__) }
  let(:gemspec)      { Gem::Specification.load(gemspec_path) }

  it "loads" do
    expect(gemspec).to be_a(Gem::Specification)
    expect(gemspec.name).to eq "keycloak-admin"
  end

  it "declares Ruby 3.1 as the minimum supported version" do
    expect(gemspec.required_ruby_version.to_s).to eq ">= 3.1"
  end

  # The CI matrix runs the oldest supported Ruby. If `required_ruby_version` is
  # ever raised without widening that matrix, or the matrix drops below what the
  # gemspec promises, this fails on the offending job instead of silently
  # shipping a gem that cannot install.
  it "is installable on the Ruby running this suite" do
    running_ruby = Gem::Version.new(RUBY_VERSION)

    expect(gemspec.required_ruby_version.satisfied_by?(running_ruby)).to be(true),
      "gemspec requires Ruby #{gemspec.required_ruby_version}, " \
      "but the suite is running on #{RUBY_VERSION}"
  end
end
