module Creneaux
  class StoreNumberOfCreneauxAvailable < BaseService
    attr_reader :category_configuration

    def initialize(category_configuration:)
      @category_configuration = category_configuration
    end

    def call
      number_of_creneaux_available = get_number_of_creneaux(
        category_configuration.motif_category,
        category_configuration.organisation
      )

      save_record!(CreneauAvailability.new(category_configuration:, number_of_creneaux_available:))
    end

    private

    def get_number_of_creneaux(motif_category, organisation)
      organisation.agents.first.with_rdv_solidarites_session do
        RdvSolidaritesApi::RetrieveCreneauAvailability.call(
          link_params: {
            motif_category_short_name: motif_category.short_name,
            organisation_ids: [organisation.rdv_solidarites_organisation_id]
          },
          total_count: true
        ).creneau_availability_count
      end
    end
  end
end
