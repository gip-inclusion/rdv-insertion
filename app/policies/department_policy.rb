class DepartmentPolicy < ApplicationPolicy
  def show?
    pundit_user.department == record
  end
end
