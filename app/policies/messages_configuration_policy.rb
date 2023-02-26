class MessagesConfigurationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      MessagesConfiguration.where(id: pundit_user.admin_organisations.map(&:messages_configuration_id))
    end
  end
end
