class ParticipationPolicy < ApplicationPolicy
  def create?
    pundit_user.organisation_ids.include?(record.organisation.id)
  end
end
