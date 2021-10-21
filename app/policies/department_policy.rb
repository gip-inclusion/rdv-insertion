class DepartmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      pundit_user.departments
    end
  end

  def list_applicants?
    pundit_user.departments.include?(record)
  end

  def invite_applicant?
    list_applicants?
  end

  def create_applicant?
    list_applicants?
  end
end
