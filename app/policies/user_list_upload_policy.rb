class UserListUploadPolicy < ApplicationPolicy
  def show?
    record.agent_id == pundit_user.id
  end

  def enrich_with_cnaf_data? = show?
end
