class ApplicantPolicy < ApplicationPolicy
  def search?
    pundit_user.department_ids.include?(record.department_id)
  end

  def index?
    search?
  end

  def invite?
    search?
  end
end
