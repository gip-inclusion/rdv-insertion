class RdvPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(organisation_id: pundit_user.organisation_ids)
    end
  end

  def show?
    record.organisation_id.in?(pundit_user.organisation_ids)
  end
end
