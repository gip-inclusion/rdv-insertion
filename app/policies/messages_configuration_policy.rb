class MessagesConfigurationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      MessagesConfiguration.where(organisation_id: pundit_user.admin_organisations_ids)
    end
  end
end
