class CategoryConfigurationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(organisation_id: pundit_user.organisation_ids)
    end
  end
end
