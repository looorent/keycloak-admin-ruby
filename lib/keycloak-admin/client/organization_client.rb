module KeycloakAdmin
  class OrganizationClient < Client
    def initialize(configuration, realm_client)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
    end

    # This endpoint does not return members
    def list(brief_representation=true, exact=nil, first=nil, max=nil, query=nil, search=nil)
      response = execute_http do
        resource(organizations_url_with_parameters(brief_representation, exact, first, max, query, search)).get(headers)
      end
      JSON.parse(response).map { |organization_as_hash| OrganizationRepresentation.from_hash(organization_as_hash) }
    end

    def count(exact=nil, query=nil, search=nil)
      response = execute_http do
        resource(count_url(exact, query, search)).get(headers)
      end
      response.to_i
    end

    def delete(organization_id)
      execute_http do
        resource(organization_url(organization_id)).delete(headers)
      end
      true
    end

    def update(organization_representation)
      execute_http do
        resource(organization_url(organization_representation.id)).put(
          create_payload(organization_representation), headers
        )
      end

      get(organization_representation.id)
    end

    def create!(name, alias_name, enabled, description, redirect_url=nil, domains=[], attributes={})
      save(build(name, alias_name, enabled, description, redirect_url, domains, attributes))
    end

    # This operation does not associate members and identity providers
    def save(organization_representation)
      execute_http do
        resource(organizations_url).post(
          create_payload(organization_representation), headers
        )
      end
      true
    end

    def get(organization_id)
      response = execute_http do
        resource(organization_url(organization_id)).get(headers)
      end
      OrganizationRepresentation.from_hash(JSON.parse(response))
    end

    def identity_providers(organization_id)
      response = execute_http do
        resource(identity_providers_url(organization_id)).get(headers)
      end
      JSON.parse(response).map { |idp_as_hash| IdentityProviderRepresentation.from_hash(idp_as_hash) }
    end

    def get_identity_provider(organization_id, identity_provider_alias)
      raise ArgumentError.new("identity_provider_alias must be defined") if identity_provider_alias.nil?
      response = execute_http do
        resource(identity_provider_url(organization_id, identity_provider_alias)).get(headers)
      end
      IdentityProviderRepresentation.from_hash(JSON.parse(response))
    end

    def add_identity_provider(organization_id, identity_provider_alias)
      raise ArgumentError.new("identity_provider_alias must be defined") if identity_provider_alias.nil?
      execute_http do
        resource(identity_providers_url(organization_id)).post(identity_provider_alias, headers)
      end
      true
    end

    def delete_identity_provider(organization_id, identity_provider_alias)
      execute_http do
        resource(identity_provider_url(organization_id, identity_provider_alias)).delete(headers)
      end
      true
    end

    def members_count(organization_id)
      response = execute_http do
        resource(members_count_url(organization_id)).get(headers)
      end
      response.to_i
    end

    def members(organization_id, exact=nil, first=nil, max=nil, membership_type=nil, search=nil)
      response = execute_http do
        resource(members_url_with_query_parameters(organization_id, exact, first, max, membership_type, search)).get(headers)
      end
      JSON.parse(response).map { |member_as_hash| MemberRepresentation.from_hash(member_as_hash) }
    end

    def invite_existing_user(organization_id, user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      execute_http do
        resource(invite_existing_user_url(organization_id)).post({id: user_id}, headers.merge(content_type: "application/x-www-form-urlencoded"))
      end
      true
    end

    def invite_user(organization_id, email, first_name, last_name)
      execute_http do
        resource(invite_user_url(organization_id)).post({
          email: email,
          firstName: first_name,
          lastName: last_name
        }, headers.merge(content_type: "application/x-www-form-urlencoded"))
      end
      true
    end

    def add_member(organization_id, user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      execute_http do
        resource(members_url(organization_id)).post(user_id, headers)
      end
      true
    end

    def delete_member(organization_id, member_id)
      execute_http do
        resource(member_url(organization_id, member_id)).delete(headers)
      end
      true
    end

    def get_member(organization_id, member_id)
      response = execute_http do
        resource(member_url(organization_id, member_id)).get(headers)
      end
      MemberRepresentation.from_hash(JSON.parse(response))
    end

    def associated_with_member(member_id, brief_representation=true)
      response = execute_http do
        resource(associated_with_member_url(member_id, brief_representation)).get(headers)
      end
      JSON.parse(response).map { |organization_as_hash| OrganizationRepresentation.from_hash(organization_as_hash) }
    end

    def organizations_url
      "#{@realm_client.realm_admin_url}/organizations"
    end

    def organization_url(organization_id)
      raise ArgumentError.new("organization_id must be defined") if organization_id.nil?
      "#{organizations_url}/#{encode_segment(organization_id)}"
    end

    def identity_providers_url(organization_id)
      "#{organization_url(organization_id)}/identity-providers"
    end

    def identity_provider_url(organization_id, identity_provider_alias)
      raise ArgumentError.new("identity_provider_alias must be defined") if identity_provider_alias.nil?
      "#{identity_providers_url(organization_id)}/#{encode_segment(identity_provider_alias)}"
    end

    def count_url(exact, query, search)
      query_parameters = build_query({exact: exact, q: query, search: search}.compact)
      "#{organizations_url}/count?#{query_parameters}"
    end

    def organizations_url_with_parameters(brief_representation, exact, first, max, query, search)
      query_parameters = build_query({
        briefRepresentation: brief_representation,
        exact: exact,
        first: first,
        max: max,
        q: query,
        search: search
      }.compact)
      "#{organizations_url}?#{query_parameters}"
    end

    def associated_with_member_url(member_id, brief_representation=true)
      "#{organizations_url}/members/#{encode_segment(member_id)}/organizations?#{build_query(briefRepresentation: brief_representation)}"
    end

    def members_count_url(organization_id)
      "#{organization_url(organization_id)}/members/count"
    end

    def member_url(organization_id, member_id)
      raise ArgumentError.new("member_id must be defined") if member_id.nil?
      "#{organization_url(organization_id)}/members/#{encode_segment(member_id)}"
    end

    def invite_existing_user_url(organization_id)
      "#{organization_url(organization_id)}/members/invite-existing-user"
    end

    def invite_user_url(organization_id)
      "#{organization_url(organization_id)}/members/invite-user"
    end

    def members_url(organization_id)
      "#{organization_url(organization_id)}/members"
    end

    def members_url_with_query_parameters(organization_id, exact, first, max, membership_type, search)
      query_parameters = build_query({
        exact: exact,
        first: first,
        max: max,
        membershipType: membership_type,
        search: search
      }.compact)
      "#{organization_url(organization_id)}/members?#{query_parameters}"
    end

    def build(name, alias_name, enabled, description, redirect_url=nil, domains=[], attributes={})
      unless domains.is_a?(Array)
        raise ArgumentError.new("domains must be an Array, got #{domains.class}")
      end

      unless domains.all? { |domain| domain.is_a?(KeycloakAdmin::OrganizationDomainRepresentation) }
        raise ArgumentError.new("All items in domains must be of type OrganizationDomainRepresentation")
      end

      organization              = OrganizationRepresentation.new
      organization.name         = name
      organization.alias        = alias_name
      organization.enabled      = enabled
      organization.description  = description
      organization.redirect_url = redirect_url
      organization.domains      = domains
      organization.attributes   = attributes
      organization
    end
  end
end
