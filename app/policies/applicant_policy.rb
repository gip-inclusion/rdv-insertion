class ApplicantPolicy < ApplicationPolicy
  def search?
    pundit_user.organisation_ids.include?(record.organisation_id)
  end

  def index?
    search?
  end

  def invite?
    search?
  end
end
