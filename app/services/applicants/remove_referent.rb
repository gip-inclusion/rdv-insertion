module Applicants
  class RemoveReferent < BaseService
    def initialize(applicant:, agent:, rdv_solidarites_session:)
      @applicant = applicant
      @agent = agent
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Applicant.transaction do
        @applicant.referents.delete(@agent)
        delete_rdv_solidarites_referent_assignation
      end
    end

    private

    def delete_rdv_solidarites_referent_assignation
      @delete_rdv_solidarites_referent_assignation ||= call_service!(
        RdvSolidaritesApi::DeleteReferentAssignation,
        user_id: @applicant.rdv_solidarites_user_id,
        agent_id: @agent.rdv_solidarites_agent_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
