class DepartmentPolicy < ApplicationPolicy
  def access?
    pundit_user.organisation_ids.intersect?(record.organisation_ids)
  end

  def show? = access?

  def index? = access?

  def batch_actions? = access?

  def parcours?(user:)
    return false unless record.with_parcours_access?

    user.organisations.any? do |organisation|
      OrganisationPolicy.new(pundit_user, organisation).parcours?
    end
  end

  class Scope < Scope
    def resolve
      scope.where(id: pundit_user.organisations.pluck(:department_id))
    end
  end
end
