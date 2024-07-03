class ArchivePolicy < ApplicationPolicy
  def create?
    pundit_user.organisations.include?(record.organisation)
  end

  def destroy?
    pundit_user.organisation_ids.intersect?(record.user.organisation_ids)
  end

  def resolve
    Archive.where(organisation_id: pundit_user.organisations.pluck(:id))
  end
end
