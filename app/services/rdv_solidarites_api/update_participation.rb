module RdvSolidaritesApi
  class UpdateParticipation < Base
    def initialize(participation_attributes:, rdv_solidarites_session:, rdv_solidarites_rdv_id:, rdv_solidarites_user_id:)
      @rdv_solidarites_session = rdv_solidarites_session
      @rdv_solidarites_rdv_id = rdv_solidarites_rdv_id
      @rdv_solidarites_user_id = rdv_solidarites_user_id
      @participation_attributes = participation_attributes
    end

    def call
      request!
      result.rdv = rdv_solidarites_response_body["rdv"]
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.update_participation(@rdv_solidarites_rdv_id, @rdv_solidarites_user_id, @participation_attributes)
    end
  end
end
