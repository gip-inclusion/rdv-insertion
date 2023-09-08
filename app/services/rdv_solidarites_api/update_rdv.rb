module RdvSolidaritesApi
  class UpdateRdv < Base
    def initialize(rdv_attributes:, rdv_solidarites_session:, rdv_solidarites_rdv_id:)
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_rdv_id = rdv_solidarites_rdv_id
      @rdv_attributes = rdv_attributes
    end

    def call
      request!
      result.rdv = rdv_solidarites_response_body["rdv"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.update_rdv(@rdv_solidarites_rdv_id, @rdv_attributes)
    end
  end
end
