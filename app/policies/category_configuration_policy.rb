class ConfigurationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Configuration.where(organisation: pundit_user.organisations)
    end
  end
end
