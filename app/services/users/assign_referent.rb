module Users
  class AssignReferent < BaseService
    def initialize(user:, agent:, rdv_solidarites_session:)
      @user = user
      @agent = agent
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      User.transaction do
        @user.referents << @agent unless @user.referents.include?(@agent)
        create_rdv_solidarites_referent_assignation
      end
    end

    private

    def create_rdv_solidarites_referent_assignation
      @create_rdv_solidarites_referent_assignation ||= call_service!(
        RdvSolidaritesApi::CreateReferentAssignation,
        user_id: @user.rdv_solidarites_user_id,
        agent_id: @agent.rdv_solidarites_agent_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
