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
end
