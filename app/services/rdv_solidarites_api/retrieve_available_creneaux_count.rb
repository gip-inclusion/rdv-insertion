module RdvSolidaritesApi
  class RetrieveAvailableCreneauxCount < Base
    def initialize(rdv_solidarites_organisation_id:, max_delay:, motif_category_short_name:, rdv_solidarites_session:)
      @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
      @max_delay = max_delay
      @motif_category_short_name = motif_category_short_name
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      request!
      result.available_creneaux_count = rdv_solidarites_response_body["available_creneaux_count"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_available_creneaux_count(
        @rdv_solidarites_organisation_id, @max_delay, @motif_category_short_name
      )
    end
  end
end
