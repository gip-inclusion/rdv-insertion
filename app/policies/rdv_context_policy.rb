class RdvContextPolicy < ApplicationPolicy
  def close?
    pundit_user.organisation_ids.intersect?(record.applicant.organisation_ids) && !record.applicant.deleted?
  end

  def reopen?
    close?
  end
end
