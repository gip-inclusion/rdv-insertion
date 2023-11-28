class RdvPolicy < ApplicationPolicy
  def show?
    record.organisation_id.in?(pundit_user.organisation_ids)
  end
end
