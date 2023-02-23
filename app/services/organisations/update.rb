module Organisations
  class Update < BaseService
    def initialize(organisation:, rdv_solidarites_session:)
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Organisation.transaction do
        check_rdv_solidarites_organisation_id
        save_record!(@organisation)
        update_rdv_solidarites_organisation
      end
    end

    private

    def check_rdv_solidarites_organisation_id
      return if @organisation.rdv_solidarites_organisation_id

      fail!("L'organisation n'est pas reliée à une organisation RDV-Solidarités")
    end

    def rdv_solidarites_organisation_attributes
      @rdv_solidarites_organisation_attributes ||= \
        @organisation.attributes
                     .symbolize_keys
                     .slice(*Organisation::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
                     .transform_values(&:presence)
                     .compact
    end

    def update_rdv_solidarites_organisation
      @update_rdv_solidarites_organisation ||= call_service!(
        RdvSolidaritesApi::UpdateOrganisation,
        organisation_attributes: rdv_solidarites_organisation_attributes,
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id
      )
    end
  end
end
