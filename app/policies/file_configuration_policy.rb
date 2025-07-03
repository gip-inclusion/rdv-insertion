class FileConfigurationPolicy < ApplicationPolicy
  def edit?
    record.organisations.all? { |o| o.id.in?(pundit_user.admin_organisations_ids) }
  end

  def update?
    edit?
  end

  def show?
    record.organisation_ids.intersect?(pundit_user.organisation_ids)
  end

  def download_template?
    show?
  end

  class Scope < Scope
    def resolve
      scope.joins(category_configurations: :organisation).where(organisations: { id: pundit_user.organisation_ids })
    end
  end
end
