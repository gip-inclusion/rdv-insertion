class DepartmentPolicy < ApplicationPolicy
  def show?
    pundit_user == record
  end
end
