class OrganisationPolicy < ApplicationPolicy
  def upload?
    pundit_user.organisations.include?(record)
  end

  def update?
    upload?
  end

  def create_and_invite_applicants?
    upload?
  end

  class Scope < Scope
    def resolve
      pundit_user.organisations
    end
  end
end
