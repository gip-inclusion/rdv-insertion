module RdvSolidaritesApi
  class DeleteReferentAssignation < Base
    def initialize(user_id:, agent_id:, rdv_solidarites_session:)
      @user_id = user_id
      @agent_id = agent_id
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      request!
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.delete_referent_assignation(@user_id, @agent_id)
    end
  end
end
