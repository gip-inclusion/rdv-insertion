module AgentRoles
  class CsvExportAuthorizationsController < ApplicationController
    before_action :set_agent_roles, :set_authorized_agent_role_ids, only: [:index]

    before_action :set_organisation, only: [:index, :batch_update]

    def index; end

    def batch_update
      if manage_export_authorizations_for_an_organisation.success?
        flash[:success] = "Les autorisations ont bien été mises à jour"
        redirect_to(organisation_category_configurations_path(@organisation))
      else
        turbo_stream_display_error_modal(manage_export_authorizations_for_an_organisation.errors)
      end
    end

    private

    def manage_export_authorizations_for_an_organisation
      @manage_export_authorizations_for_an_organisation ||=
        AgentRoles::ManageExportAuthorizationsForAnOrganisation.call(
          organisation: @organisation,
          agent_roles: agent_roles_to_authorize
        )
    end

    def agent_roles_to_authorize
      @agent_roles_to_authorize ||= @organisation.agent_roles.basic.where(
        id: csv_export_authorizations_params[:agent_role_ids]
      )
    end

    def set_agent_roles
      @agent_roles = @organisation.agent_roles
                                  .basic
                                  .joins(:agent)
                                  .where.not(agent: { last_name: nil })
                                  .select("agent_roles.*, agent.email")
                                  .order("agent.email desc")
    end

    def set_authorized_agent_role_ids
      @authorized_agent_role_ids = @agent_roles.authorized_to_export_csv.distinct.map(&:id)
    end

    def csv_export_authorizations_params
      params.expect(csv_export_authorizations: [:organisation_id, { agent_role_ids: [] }])
    end

    def set_organisation
      @organisation = Organisation.find(params[:organisation_id])
      authorize @organisation, :configure?
    end
  end
end
