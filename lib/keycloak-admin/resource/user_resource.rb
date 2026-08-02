# frozen_string_literal: true
module KeycloakAdmin
  class UserResource < BaseRoleContainingResource
    def resources_name
      "users"
    end
  end
end
