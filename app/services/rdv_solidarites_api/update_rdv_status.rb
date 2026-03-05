module RdvSolidaritesApi
  class UpdateRdvStatus < Base
    def initialize(rdv_solidarites_rdv_id:, status:)
      @rdv_solidarites_rdv_id = rdv_solidarites_rdv_id
      @status = status
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.update_rdv_status(@rdv_solidarites_rdv_id, @status)
    end
  end
end
