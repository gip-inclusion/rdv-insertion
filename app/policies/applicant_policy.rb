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

  def show?
    (pundit_user.organisation_ids & record.organisations.pluck(:rdv_solidarites_organisation_id)).empty?
  end
end
