class ConfigurationPolicy < ApplicationPolicy
  def update?
    record.organisations.to_a.intersection(pundit_user.organisations.to_a).any?
  end

  def new?
    update?
  end

  def create?
    update?
  end

  class Scope < Scope
    def resolve
      Configuration.joins(:organisations).where(organisations: pundit_user.organisations)
    end
  end
end
