class RdvPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:organisation).where(organisations: pundit_user.organisations)
    end
  end

  def show?
    record.organisation_id.in?(pundit_user.organisation_ids)
  end
end
