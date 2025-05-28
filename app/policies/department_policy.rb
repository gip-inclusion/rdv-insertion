class DepartmentPolicy < ApplicationPolicy
  def access?
    pundit_user.organisation_ids.intersect?(record.organisation_ids)
  end

  def show? = access?

  def index? = access?

  def batch_actions? = access?

  def parcours?
    return false unless record.with_parcours_access?

    pundit_user
      .organisations
      .pluck(:organisation_type)
      .intersect?(Organisation::ORGANISATION_TYPES_WITH_PARCOURS_ACCESS)
  end

  class Scope < Scope
    def resolve
      scope.where(id: pundit_user.organisations.pluck(:department_id))
    end
  end
end
