module RdvSolidaritesApi
  class CreateMotifCategoryTerritory < Base
    def initialize(motif_category_short_name:, organisation_id:)
      @motif_category_short_name = motif_category_short_name
      @organisation_id = organisation_id
      @rdv_solidarites_session = rdv_solidarites_session_with_shared_secret
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||=
        rdv_solidarites_client.create_motif_category_territory(@motif_category_short_name, @organisation_id)
    end
  end
end
