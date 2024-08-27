module Organisations
  class Create < BaseService
    def initialize(organisation:, agent: Current.agent)
      @organisation = organisation
      @agent = agent
    end

    def call
      Organisation.transaction do
        check_rdv_solidarites_organisation_id
        save_record!(@organisation)
        upsert_rdv_solidarites_webhook_endpoint
      end
      trigger_rdv_solidarites_webhook_endpoint
    end

    private

    def check_rdv_solidarites_organisation_id
      return if @organisation.rdv_solidarites_organisation_id?

      fail!("L'ID de l'organisation RDV-Solidarités n'a pas été renseigné correctement")
    end

    def upsert_rdv_solidarites_webhook_endpoint
      # webhook_endpoint is upserted but not triggered because organisation is not persisted yet
      rdv_solidarites_webhook_endpoint.present? ? update_rdvs_webhook_endpoint : create_rdvs_webhook_endpoint
    end

    def trigger_rdv_solidarites_webhook_endpoint
      TriggerRdvSolidaritesWebhooksJob.perform_async(
        rdv_solidarites_webhook_endpoint_id,
        @organisation.rdv_solidarites_organisation_id
      )
    end

    def rdv_solidarites_organisation
      @rdv_solidarites_organisation ||= call_service!(
        RdvSolidaritesApi::RetrieveOrganisation,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
      ).organisation
    end

    def create_rdvs_webhook_endpoint
      @create_rdvs_webhook_endpoint ||= call_service!(
        RdvSolidaritesApi::CreateWebhookEndpoint,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
      )
    end

    def update_rdvs_webhook_endpoint
      @update_rdvs_webhook_endpoint ||= call_service!(
        RdvSolidaritesApi::UpdateWebhookEndpoint,
        rdv_solidarites_webhook_endpoint_id: rdv_solidarites_webhook_endpoint_id,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
      )
    end

    def rdv_solidarites_webhook_endpoint
      @rdv_solidarites_webhook_endpoint ||= call_service!(
        RdvSolidaritesApi::RetrieveWebhookEndpoint,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
      ).webhook_endpoint
    end

    def rdv_solidarites_webhook_endpoint_id
      @rdv_solidarites_webhook_endpoint_id ||=
        rdv_solidarites_webhook_endpoint&.id || create_rdvs_webhook_endpoint.webhook_endpoint_id
    end
  end
end
