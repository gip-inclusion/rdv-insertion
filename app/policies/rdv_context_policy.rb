class RdvContextPolicy < ApplicationPolicy
  def new?
    pundit_user.department_ids.include?(record.applicant.department_id)
  end

  def create?
    new?
  end
end
