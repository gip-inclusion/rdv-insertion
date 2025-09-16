module Creneaux
  class StoreNumberOfCreneauxAvailable < BaseService
    MAX_RELEVANT_CRENEAUX_COUNT_LIMIT = 200

    attr_reader :category_configuration

    def initialize(category_configuration:)
      @category_configuration = category_configuration
    end

    def call
      number_of_creneaux_available = get_number_of_creneaux(
        category_configuration.motif_category,
        category_configuration.organisation
      )

      save_record!(CreneauAvailability.new(category_configuration:, number_of_creneaux_available:,
                                           number_of_pending_invitations:))
    end

    private

    def get_number_of_creneaux(motif_category, organisation)
      organisation.agents.first.with_rdv_solidarites_session do
        call_service!(
          RdvSolidaritesApi::RetrieveCreneauAvailability,
          link_params: {
            motif_category_short_name: motif_category.short_name,
            organisation_ids: [organisation.rdv_solidarites_organisation_id]
          },
          total_count: true,
          max_relevant_creneaux_count_limit: MAX_RELEVANT_CRENEAUX_COUNT_LIMIT
        ).creneau_availability_count
      end
    end

    def number_of_pending_invitations
      Invitation.joins(:follow_up, :organisations)
                .where(follow_ups: { motif_category_id: category_configuration.motif_category_id })
                .where(organisations: { id: category_configuration.organisation_id })
                .valid
                .count
    end
  end
end
