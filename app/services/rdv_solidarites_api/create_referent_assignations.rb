module RdvSolidaritesApi
  class CreateReferentAssignations < Base
    def initialize(rdv_solidarites_user_id:, rdv_solidarites_agent_ids:)
      @rdv_solidarites_user_id = rdv_solidarites_user_id
      @rdv_solidarites_agent_ids = rdv_solidarites_agent_ids
      @rdv_solidarites_session = rdv_solidarites_session_with_shared_secret
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||=
        rdv_solidarites_client.create_referent_assignations(@rdv_solidarites_user_id, @rdv_solidarites_agent_ids)
    end
  end
end
