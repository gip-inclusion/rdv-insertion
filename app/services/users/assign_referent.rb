module Users
  class AssignReferent < BaseService
    def initialize(user:, agent:)
      @user = user
      @agent = agent
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
        rdv_solidarites_user_id: @user.rdv_solidarites_user_id,
        rdv_solidarites_agent_id: @agent.rdv_solidarites_agent_id
      )
    end
  end
end
