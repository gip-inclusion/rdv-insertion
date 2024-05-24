class AgentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:departments).where(departments: pundit_user.departments)
    end
  end
end
