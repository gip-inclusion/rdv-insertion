class CategoryConfigurationPolicy < ApplicationPolicy
  def show?
    pundit_user.organisation_ids.include?(record.organisation_id)
  end

  class Scope < Scope
    def resolve
      scope.where(organisation_id: pundit_user.organisation_ids)
    end
  end
end
