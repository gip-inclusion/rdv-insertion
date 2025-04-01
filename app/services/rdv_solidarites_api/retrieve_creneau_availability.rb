module RdvSolidaritesApi
  class RetrieveCreneauAvailability < Base
    def initialize(link_params:, total_count: false, max_relevant_creneaux_count_limit: nil)
      @link_params = link_params.merge(total_count:, max_relevant_creneaux_count_limit:)
    end

    def call
      request!
      result.creneau_availability = rdv_solidarites_response_body["creneau_availability"]
      result.creneau_availability_count = rdv_solidarites_response_body["creneau_availability_count"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_creneau_availability(@link_params)
    end
  end
end
