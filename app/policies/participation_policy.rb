class ParticipationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:organisation).where(organisations: pundit_user.organisations)
    end
  end

  def create?
    pundit_user.organisation_ids.include?(record.organisation.id)
  end
end
