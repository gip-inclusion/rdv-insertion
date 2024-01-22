module Users
  class RemoveReferent < BaseService
    def initialize(user:, agent:)
      @user = user
      @agent = agent
    end

    def call
      User.transaction do
        @user.referents.delete(@agent)
        delete_rdv_solidarites_referent_assignation
      end
    end

    private

    def delete_rdv_solidarites_referent_assignation
      @delete_rdv_solidarites_referent_assignation ||= call_service!(
        RdvSolidaritesApi::DeleteReferentAssignation,
        rdv_solidarites_user_id: @user.rdv_solidarites_user_id,
        rdv_solidarites_agent_id: @agent.rdv_solidarites_agent_id
      )
    end
  end
end
