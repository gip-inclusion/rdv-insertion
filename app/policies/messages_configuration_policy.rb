class MessagesConfigurationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      MessagesConfiguration.where(
        id: Organisation.where(id: pundit_user.admin_organisations_ids).map(&:messages_configuration_id)
      )
    end
  end
end
