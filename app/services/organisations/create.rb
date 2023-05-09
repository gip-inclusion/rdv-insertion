module Organisations
  class Create < BaseService
    def initialize(organisation:, current_agent:, rdv_solidarites_session:)
      @organisation = organisation
      @current_agent = current_agent
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Organisation.transaction do
        check_rdv_solidarites_organisation_id
        assign_rdv_solidarites_organisation_attributes
        save_record!(@organisation)
        save_record!(agent_role_for_new_organisation)
        upsert_rdv_solidarites_webhook_endpoint
        tag_rdv_solidarites_organisation
      end
    end

    private

    def upsert_rdv_solidarites_webhook_endpoint
      rdv_solidarites_webhook_endpoint.present? ? update_rdvs_webhook_endpoint : create_rdvs_webhook_endpoint
    end

    def check_rdv_solidarites_organisation_id
      return if @organisation.rdv_solidarites_organisation_id

      fail!("L'ID de l'organisation RDV-Solidarités n'a pas été renseigné correctement")
    end

    def assign_rdv_solidarites_organisation_attributes
      @organisation.assign_attributes(rdv_solidarites_organisation.attributes.except(:id))
    end

    def agent_role_for_new_organisation
      # to allow an instant redirection, we create the agent_role directl
      # the rdv_solidarites_agent_role_id will be added to this agent_role record thanks to the webhook
      # this is safe because the transaction succeeds only if the agent is a territorial admin in the department
      @agent_role_for_new_organisation ||=
        AgentRole.new(agent_id: @current_agent.id, organisation_id: @organisation.id, level: "admin")
    end

    def rdv_solidarites_organisation
      @rdv_solidarites_organisation ||= call_service!(
        RdvSolidaritesApi::RetrieveOrganisation,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_session: @rdv_solidarites_session
      ).organisation
    end

    def create_rdvs_webhook_endpoint
      @create_rdvs_webhook_endpoint ||= call_service!(
        RdvSolidaritesApi::CreateWebhookEndpoint,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def update_rdvs_webhook_endpoint
      @update_rdvs_webhook_endpoint ||= call_service!(
        RdvSolidaritesApi::UpdateWebhookEndpoint,
        rdv_solidarites_webhook_endpoint_id: rdv_solidarites_webhook_endpoint.id,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end

    def rdv_solidarites_webhook_endpoint
      @rdv_solidarites_webhook_endpoint ||= call_service!(
        RdvSolidaritesApi::RetrieveWebhookEndpoint,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_session: @rdv_solidarites_session
      ).webhook_endpoint
    end

    def tag_rdv_solidarites_organisation
      @tag_rdv_solidarites_organisation ||= call_service!(
        RdvSolidaritesApi::UpdateOrganisation,
        organisation_attributes: { "verticale" => "rdv_insertion" },
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
      )
    end
  end
end
