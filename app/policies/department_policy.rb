class DepartmentPolicy < ApplicationPolicy
  def upload?
    pundit_user.organisation_ids.intersect?(record.organisation_ids)
  end

  def show? = upload?

  def index? = upload?

  def batch_actions? = upload?

  def parcours?
    record.number.in?(ENV["DEPARTMENTS_WHERE_PARCOURS_ENABLED"].split(",")) &&
      pundit_user.organisations.pluck(:organisation_type).intersect?(%w[delegataire_rsa conseil_departemental
                                                                        france_travail])
  end

  class Scope < Scope
    def resolve
      Department.where(id: pundit_user.organisations.pluck(:department_id))
    end
  end
end
