class OrganisationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      pundit_user.organisations
    end
  end

  def list_applicants?
    pundit_user.organisations.include?(record)
  end

  def invite_applicant?
    list_applicants?
  end

  def create_applicant?
    list_applicants?
  end

  def update_applicant?
    list_applicants?
  end
end
