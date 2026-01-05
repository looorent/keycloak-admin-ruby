module KeycloakAdmin
  class OrganizationRepresentation < Representation
    attr_accessor :id,
      :name,
      :alias,
      :enabled,
      :description,
      :redirect_url,
      :attributes,
      :domains,
      :members,
      :attributes,
      :identity_providers

    def self.from_hash(hash)
      role                    = new
      role.id                 = hash["id"]
      role.name               = hash["name"]
      role.alias              = hash["alias"]
      role.enabled            = hash["enabled"]
      role.description        = hash["description"]
      role.redirect_url       = hash["redirectUrl"]
      role.attributes         = hash["attributes"] || {}
      role.domains            = hash["domains"].nil? ? [] : hash["domains"].map { |domain| KeycloakAdmin::OrganizationDomainRepresentation.from_hash(domain) }
      role.members            = hash["members"].nil? ? [] : hash["members"].map { |member| KeycloakAdmin::MemberRepresentation.from_hash(member) }
      role.identity_providers = hash["identityProviders"].nil? ? [] : hash["identityProviders"].map { |provider| KeycloakAdmin::IdentityProviderRepresentation.from_hash(provider) }
      role
    end
  end
end
