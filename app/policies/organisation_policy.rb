class OrganisationPolicy < ApplicationPolicy
  def upload?
    pundit_user.organisations.include?(record)
  end

  class Scope < Scope
    def resolve
      pundit_user.organisations
    end
  end
end
