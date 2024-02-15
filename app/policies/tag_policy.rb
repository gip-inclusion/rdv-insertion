class TagPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:organisations).where(organisations: pundit_user.organisations)
    end
  end
end
