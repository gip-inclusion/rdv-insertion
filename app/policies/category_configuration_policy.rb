class CategoryConfigurationPolicy < ApplicationPolicy
  def show?
    pundit_user.organisation_ids.include?(record.organisation_id)
  end

  def edit?
    record.organisation_id.in?(pundit_user.admin_organisations_ids)
  end

  class Scope < Scope
    def resolve
      scope.where(organisation_id: pundit_user.organisation_ids)
    end
  end
end
