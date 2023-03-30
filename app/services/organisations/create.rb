module Organisations
  class Create < BaseService
    def initialize(organisation:, rdv_solidarites_session:)
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Organisation.transaction do
        check_rdv_solidarites_organisation_id
        assign_rdv_solidarites_organisation_attributes
        save_record!(@organisation)
        upsert_rdv_solidarites_webhook_endpoint
        # add 1 context
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
      @organisation.assign_attributes(retrieve_rdv_solidarites_organisation.organisation.attributes.except(:id))
    end

    def retrieve_rdv_solidarites_organisation
      @retrieve_rdv_solidarites_organisation ||= call_service!(
        RdvSolidaritesApi::RetrieveOrganisation,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
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
  end
end
