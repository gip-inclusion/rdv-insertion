module RdvSolidaritesApi
  class CreateMotifCategory < Base
    def initialize(motif_category_attributes:)
      @motif_category_attributes = motif_category_attributes
      @rdv_solidarites_session = rdv_solidarites_session_with_shared_secret
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.create_motif_category(@motif_category_attributes)
    end
  end
end
