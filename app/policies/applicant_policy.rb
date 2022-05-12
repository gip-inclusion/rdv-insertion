class ApplicantPolicy < ApplicationPolicy
  def new?
    pundit_user.department_ids.include?(record.department_id)
  end

  def create?
    new?
  end

  def show?
    (pundit_user.organisation_ids & record.organisation_ids).any? && !record.deleted?
  end

  def search?
    show?
  end

  def invite?
    show?
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
