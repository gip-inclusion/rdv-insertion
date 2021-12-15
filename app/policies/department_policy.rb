class DepartmentPolicy < ApplicationPolicy
  def upload?
    (record.organisation_ids - pundit_user.organisation_ids).empty?
  end
end
