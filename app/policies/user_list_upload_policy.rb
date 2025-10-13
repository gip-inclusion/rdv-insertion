class UserListUploadPolicy < ApplicationPolicy
  def create?
    record.organisations.intersect?(pundit_user.organisations)
  end
  def create_from_existing_users? = create?

  def show?
    record.agent_id == pundit_user.id
  end

  def edit? = show?

  def enrich_with_cnaf_data? = show?
end
