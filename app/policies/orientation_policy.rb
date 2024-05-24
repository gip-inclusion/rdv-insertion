class OrientationPolicy < ApplicationPolicy
  def edit?
    record.user.organisation_ids.intersect?(pundit_user.organisation_ids)
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  class Scope < Scope
    def resolve
      scope.joins(:organisation).where(organisation: { department_id: pundit_user.organisations.pluck(:department_id) })
    end
  end
end
