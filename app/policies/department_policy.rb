class DepartmentPolicy < ApplicationPolicy
  def list_applicants?
    pundit_user.departments.include?(record)
  end

  def create_applicant?
    list_applicants?
  end
end
