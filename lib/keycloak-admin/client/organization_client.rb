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
        RestClient::Resource.new(organizations_url_with_parameters(brief_representation, exact, first, max, query, search), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |organization_as_hash| OrganizationRepresentation.from_hash(organization_as_hash) }
    end

    def count(exact=nil, query=nil, search=nil)
      response = execute_http do
        RestClient::Resource.new(count_url(exact, query, search), @configuration.rest_client_options).get(headers)
      end
      response.to_i
    end

    def delete(organization_id)
      execute_http do
        RestClient::Resource.new(organization_url(organization_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def update(organization_representation)
      execute_http do
        RestClient::Resource.new(organization_url(organization_representation.id), @configuration.rest_client_options).put(
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
        RestClient::Resource.new(organizations_url, @configuration.rest_client_options).post(
          create_payload(organization_representation), headers
        )
      end
      true
    end

    def get(organization_id)
      response = execute_http do
        RestClient::Resource.new(organization_url(organization_id), @configuration.rest_client_options).get(headers)
      end
      OrganizationRepresentation.from_hash(JSON.parse(response))
    end

    def identity_providers(organization_id)
      response = execute_http do
        RestClient::Resource.new(identity_providers_url(organization_id), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |idp_as_hash| IdentityProviderRepresentation.from_hash(idp_as_hash) }
    end

    def get_identity_provider(organization_id, identity_provider_alias)
      raise ArgumentError.new("identity_provider_alias must be defined") if identity_provider_alias.nil?
      response = execute_http do
        RestClient::Resource.new("#{identity_providers_url(organization_id)}/#{identity_provider_alias}", @configuration.rest_client_options).get(headers)
      end
      IdentityProviderRepresentation.from_hash(JSON.parse(response))
    end

    def add_identity_provider(organization_id, identity_provider_alias)
      raise ArgumentError.new("identity_provider_alias must be defined") if identity_provider_alias.nil?
      execute_http do
        RestClient::Resource.new(identity_providers_url(organization_id), @configuration.rest_client_options).post(identity_provider_alias, headers)
      end
      true
    end

    def delete_identity_provider(organization_id, identity_provider_alias)
      execute_http do
        RestClient::Resource.new(identity_provider_url(organization_id, identity_provider_alias), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def members_count(organization_id)
      response = execute_http do
        RestClient::Resource.new(members_count_url(organization_id), @configuration.rest_client_options).get(headers)
      end
      response.to_i
    end

    def members(organization_id, exact=nil, first=nil, max=nil, membership_type=nil, search=nil)
      response = execute_http do
        RestClient::Resource.new(members_url_with_query_parameters(organization_id, exact, first, max, membership_type, search), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |member_as_hash| MemberRepresentation.from_hash(member_as_hash) }
    end

    def invite_existing_user(organization_id, user_id)
      raise ArgumentError.new("user_id must be defined") if user_id.nil?
      execute_http do
        RestClient::Resource.new(invite_existing_user_url(organization_id), @configuration.rest_client_options).post({id: user_id}, headers.merge(content_type: "application/x-www-form-urlencoded"))
      end
      true
    end

    def invite_user(organization_id, email, first_name, last_name)
      execute_http do
        RestClient::Resource.new(invite_user_url(organization_id), @configuration.rest_client_options).post({
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
        RestClient::Resource.new(members_url(organization_id), @configuration.rest_client_options).post(user_id, headers)
      end
      true
    end

    def delete_member(organization_id, member_id)
      execute_http do
        RestClient::Resource.new(member_url(organization_id, member_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def get_member(organization_id, member_id)
      response = execute_http do
        RestClient::Resource.new(member_url(organization_id, member_id), @configuration.rest_client_options).get(headers)
      end
      MemberRepresentation.from_hash(JSON.parse(response))
    end

    def associated_with_member(member_id, brief_representation=true)
      response = execute_http do
        RestClient::Resource.new(associated_with_member_url(member_id, brief_representation), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |organization_as_hash| OrganizationRepresentation.from_hash(organization_as_hash) }
    end

    def organizations_url
      "#{@realm_client.realm_admin_url}/organizations"
    end

    def organization_url(organization_id)
      raise ArgumentError.new("organization_id must be defined") if organization_id.nil?
      "#{organizations_url}/#{organization_id}"
    end

    def identity_providers_url(organization_id)
      "#{organization_url(organization_id)}/identity-providers"
    end

    def identity_provider_url(organization_id, identity_provider_alias)
      raise ArgumentError.new("identity_provider_alias must be defined") if identity_provider_alias.nil?
      "#{identity_providers_url(organization_id)}/#{identity_provider_alias}"
    end

    def count_url(exact, query, search)
      query_parameters = {exact: exact, q: query, search: search}.compact.to_a.map { |e| "#{e[0]}=#{e[1]}" }.join("&")
      "#{organizations_url}/count?#{query_parameters}"
    end

    def organizations_url_with_parameters(brief_representation, exact, first, max, query, search)
      query_parameters = {
        briefRepresentation: brief_representation,
        exact: exact,
        first: first,
        max: max,
        q: query,
        search: search
      }.compact.to_a.map { |e| "#{e[0]}=#{e[1]}" }.join("&")
      "#{organizations_url}?#{query_parameters}"
    end

    def associated_with_member_url(member_id, brief_representation=true)
      "#{organizations_url}/members/#{member_id}/organizations?briefRepresentation=#{brief_representation}"
    end

    def members_count_url(organization_id)
      "#{organization_url(organization_id)}/members/count"
    end

    def member_url(organization_id, member_id)
      raise ArgumentError.new("member_id must be defined") if member_id.nil?
      "#{organization_url(organization_id)}/members/#{member_id}"
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
      query_parameters = {
        exact: exact,
        first: first,
        max: max,
        membershipType: membership_type,
        search: search
      }.compact.to_a.map { |e| "#{e[0]}=#{e[1]}" }.join("&")
      "#{organization_url(organization_id)}/members?#{query_parameters}"
    end

    def build(name, alias_name, enabled, description, redirect_url=nil, domains=[], attributes={})
      unless domains.is_a?(Array)
        raise ArgumentError.new("domains must be an Array, got #{new_domains.class}")
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
