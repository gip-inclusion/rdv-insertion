class InvitationPolicy < ApplicationPolicy
  def create?
    pundit_user.organisation_ids.intersect?(record.user.organisation_ids)
  end
end
