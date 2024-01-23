class ParcoursDocumentPolicy < ApplicationPolicy
  def edit?
    record.agent == pundit_user
  end
  alias update? edit?
  alias destroy? edit?
end
