class PostRdvOrientationPolicy < ApplicationPolicy
  def create?
    pundit_user.organisation_ids.include?(record.organisation_id)
  end
end
