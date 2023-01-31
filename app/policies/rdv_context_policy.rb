class RdvContextPolicy < ApplicationPolicy
  def create?
    pundit_user.department_ids.include?(record.applicant&.department_id)
  end
end
