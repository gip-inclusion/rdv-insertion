class ParcoursDocumentPolicy < ApplicationPolicy
  def edit?
    record.agent == pundit_user
  end
  alias update? edit?
  alias destroy? edit?

  def show?
    pundit_user.organisations.intersect?(record.user.organisations)
  end
end
