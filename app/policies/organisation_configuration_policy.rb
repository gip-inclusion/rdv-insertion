class OrganisationConfigurationPolicy < ApplicationPolicy
  # in this policy, we authorize the organisation record to which the configurations and file_configurations are
  # attached because of the many to many relation between configurations and organisations and because we need to check
  # the admin privileges which are tied to the organsiation record

  def index?
    pundit_user.admin_organisations.include?(record)
  end

  def show?
    index?
  end

  def new?
    index?
  end

  def edit?
    index?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

  class Scope < Scope
    def resolve
      Configuration.joins(:organisations).where(organisations: pundit_user.admin_organisations)
    end
  end
end
