class AgentRolesController < ApplicationController
  before_action :set_organisation, :set_agent_roles, :set_authorized_agent_role_ids, only: [:index]

  def index; end

  def create
    if manage_export_authorizations_for_an_organisation.success?
      redirect_to(organisation_category_configurations_path(current_organisation))
    else
      turbo_stream_display_error_modal(manage_export_authorizations_for_an_organisation.errors)
    end
  end

  private

  def manage_export_authorizations_for_an_organisation
    @manage_export_authorizations_for_an_organisation ||=
      AgentRoles::ManageExportAuthorizationsForAnOrganisation.call(
        organisation: current_organisation,
        agent_roles: agent_roles_to_authorize
      )
  end

  def agent_roles_to_authorize
    @agent_roles_to_authorize ||= AgentRole.where(id: export_authorization_params[:agent_role_ids])
  end

  def set_agent_roles
    @agent_roles = current_organisation.agent_roles
                                       .basic
                                       .joins(:agent)
                                       .where.not(agent: { last_name: nil })
  end

  def set_authorized_agent_role_ids
    @authorized_agent_role_ids = @agent_roles.with_export_authorization.distinct.map(&:id)
  end

  def export_authorization_params
    params.require(:export_authorization).permit(:organisation_id, agent_role_ids: [])
  end

  def set_organisation
    @organisation = current_organisation
  end
end
