class TagPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:organisations).where(organisations: pundit_user.organisations)
    end
  end

  def show?
    record.tag_organisations.map(&:organisation_id).intersect?(pundit_user.organisation_ids)
  end
end
