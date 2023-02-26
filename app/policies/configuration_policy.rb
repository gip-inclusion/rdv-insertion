class ConfigurationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Configuration.joins(:organisations).where(organisations: pundit_user.admin_organisations)
    end
  end
end
