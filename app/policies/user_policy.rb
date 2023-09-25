class UserPolicy < ApplicationPolicy
  def new?
    true
  end

  def show?
    pundit_user.organisation_ids.intersect?(record.organisation_ids) && !record.deleted?
  end

  def update?
    show?
  end

  def edit?
    show?
  end

  class Scope < Scope
    def resolve
      scope.joins(:organisations).where(organisations: pundit_user.organisations)
    end
  end
end
