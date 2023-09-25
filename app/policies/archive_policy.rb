class ArchivePolicy < ApplicationPolicy
  def create?
    # agent must belong to all orgs where the user is present inside the department
    record.user.organisations.all? do |organisation|
      organisation.department_id != record.department_id ||
        organisation.id.in?(pundit_user.organisation_ids)
    end
  end

  def destroy?
    pundit_user.organisation_ids.intersect?(record.user.organisation_ids)
  end
end
