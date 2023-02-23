class MessagesConfigurationPolicy < ApplicationPolicy
  def update?
    record.organisations.to_a.intersection(pundit_user.organisations.to_a).any?
  end

  class Scope < Scope
    def resolve
      MessagesConfiguration.where(id: pundit_user.organisations.map(&:messages_configuration_id))
    end
  end
end
