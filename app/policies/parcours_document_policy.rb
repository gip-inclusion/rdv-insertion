class ParcoursDocumentPolicy < ApplicationPolicy
  def create?
    record.agent == pundit_user || admin_in_user_parcours_org?
  end
  alias edit? create?
  alias update? create?
  alias destroy? create?

  def show?
    in_user_parcours_org?
  end

  private

  def admin_in_user_parcours_org?
    pundit_user.admin_organisations.select(&:with_parcours_access?).intersect?(record.user.organisations)
  end

  def in_user_parcours_org?
    pundit_user.organisations.select(&:with_parcours_access?).intersect?(record.user.organisations)
  end
end
