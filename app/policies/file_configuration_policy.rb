class FileConfigurationPolicy < ApplicationPolicy
  def edit?
    if record.no_category_configuration?
      record.created_by_agent == pundit_user
    else
      record.organisations.all? { |o| o.id.in?(pundit_user.admin_organisations_ids) }
    end
  end

  def update?
    edit?
  end

  def show?
    if record.no_category_configuration?
      record.created_by_agent == pundit_user
    else
      record.organisation_ids.intersect?(pundit_user.organisation_ids)
    end
  end

  def download_template?
    show?
  end

  class Scope < Scope
    def resolve
      organisation_scope_ids = scope.joins(category_configurations: :organisation)
                                    .where(organisations: { id: pundit_user.organisation_ids })
                                    .pluck(:id)
      agent_scope_ids = scope.where(created_by_agent: pundit_user).pluck(:id)

      scope.where(id: organisation_scope_ids + agent_scope_ids).distinct
    end
  end
end
