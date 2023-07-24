class ConfigurationPolicy < ApplicationPolicy
  def show?
    pundit_user.organisation_ids.include?(record.organisation_id)
  end

  def edit?
    pundit_user.admin_organisations_ids.include?(record.organisation_id)
  end

  def update?
    edit?
  end

  class Scope < Scope
    def resolve
      Configuration.where(organisation: pundit_user.organisations)
    end
  end
end
