class CreneauOpeningRequestPolicy < ApplicationPolicy
  def create?
    record.user_list_upload.agent_id == pundit_user.id
  end
end
