module Configurations
  class UpdateAvailableCreneauxCount < BaseService
    delegate :available_creneaux_count, to: :retrieve_available_creneaux_count

    def initialize(configuration:, rdv_solidarites_session:)
      @configuration = configuration
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Configuration.transaction do
        @configuration.available_creneaux_count = available_creneaux_count
        save_record!(@configuration)
      end
    end

    def retrieve_available_creneaux_count
      @retrieve_available_creneaux_count ||= call_service!(
        RdvSolidaritesApi::RetrieveAvailableCreneauxCount,
        rdv_solidarites_session: @rdv_solidarites_session,
        motif_category_short_name: @configuration.motif_category.short_name,
        max_delay: @configuration.number_of_days_before_action_required,
        rdv_solidarites_organisation_id: @configuration.organisation.rdv_solidarites_organisation_id
      )
    end
  end
end
