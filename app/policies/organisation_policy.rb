class OrganisationPolicy < ApplicationPolicy
  def upload?
    pundit_user.organisations.include?(record)
  end

  def create?
    pundit_user.super_admin?
  end

  def new?
    create?
  end

  def update?
    configure?
  end

  def create_and_invite_users?
    upload?
  end

  def configure?
    pundit_user.admin_organisations_ids.include?(record.id)
  end

  class Scope < Scope
    def resolve
      pundit_user.organisations
    end
  end
end
