class InvitationPolicy < ApplicationPolicy
  def create?
    pundit_user.organisation_ids.intersect?(record.applicant.organisation_ids)
  end
end
