module RdvSolidaritesApi
  class CreateReferentAssignations < Base
    def initialize(rdv_solidarites_session:, user_id:, agent_ids:)
      @rdv_solidarites_session = rdv_solidarites_session
      @user_id = user_id
      @agent_ids = agent_ids
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.create_referent_assignations(@user_id, @agent_ids)
    end
  end
end
