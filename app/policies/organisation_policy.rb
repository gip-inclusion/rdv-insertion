class OrganisationPolicy < ApplicationPolicy
  def access?
    pundit_user.organisations.include?(record)
  end

  def create?
    pundit_user.super_admin?
  end

  def show?
    configure?
  end

  def new?
    create?
  end

  def update?
    configure?
  end

  def update_data_retention?
    configure?
  end

  def edit?
    configure?
  end

  def create_and_invite_users?
    access?
  end

  def batch_actions?
    access?
  end

  def parcours?
    access? && record.with_parcours_access?
  end

  def unassign?
    access?
  end

  def configure?
    pundit_user.admin_organisations_ids.include?(record.id)
  end

  def can_accept_dpa?
    configure?
  end

  def export_csv?
    pundit_user.export_organisations_ids.include?(record.id)
  end

  class Scope < Scope
    def resolve
      scope.where(id: pundit_user.organisation_ids)
    end
  end
end
