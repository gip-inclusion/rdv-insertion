class DepartmentPolicy < ApplicationPolicy
  def upload?
    (pundit_user.organisation_ids & record.organisation_ids).any?
  end

  def index?
    upload?
  end
end
