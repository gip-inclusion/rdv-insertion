class ParcoursDocumentPolicy < ApplicationPolicy
  def edit?
    record.agent == pundit_user || admin_in_user_parcours_org?
  end
  alias update? edit?
  alias destroy? edit?

  def show?
    in_user_parcours_org?
  end
  alias create? show?

  private

  def admin_in_user_parcours_org?
    pundit_user.admin_organisations.select(&:with_parcours_access?).intersect?(record.user.organisations)
  end

  def in_user_parcours_org?
    pundit_user.organisations.select(&:with_parcours_access?).intersect?(record.user.organisations)
  end
end
