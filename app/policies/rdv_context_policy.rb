class RdvContextPolicy < ApplicationPolicy
  def close?
    pundit_user.organisation_ids.intersect?(record.applicant.organisation_ids) &&
      !record.applicant.deleted? &&
      pundit_user.motif_categories.include?(record.motif_category)
  end

  def reopen?
    close?
  end
end
