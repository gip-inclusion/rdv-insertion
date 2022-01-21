class InvitationPolicy < ApplicationPolicy
  def create?
    (pundit_user.organisation_ids & record.applicant.organisation_ids).any?
  end
end
