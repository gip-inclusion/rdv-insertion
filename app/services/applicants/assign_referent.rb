module Applicants
  class AssignReferent < BaseService
    def initialize(applicant:, agent:, rdv_solidarites_session:)
      @applicant = applicant
      @agent = agent
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Applicant.transaction do
        @applicant.referents << @agent
        create_rdv_solidarites_referent_assignation
      end
    end

    private

    def create_rdv_solidarites_referent_assignation
      @create_rdv_solidarites_referent_assignation ||= call_service!(
        RdvSolidaritesApi::CreateReferentAssignation,
        user_id: @applicant.rdv_solidarites_user_id,
        agent_id: @agent.rdv_solidarites_agent_id,
        rdv_solidarites_session: @rdv_solidarites_session
      )
    end
  end
end
