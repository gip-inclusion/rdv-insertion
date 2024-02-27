class ParticipationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:organisation).where(organisations: pundit_user.organisations)
    end
  end

  def create?
    member_of_organisation?
  end

  def edit?
    member_of_organisation?
  end

  private

  def member_of_organisation?
    pundit_user.organisation_ids.include?(record.organisation.id)
  end
end
