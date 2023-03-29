module RdvSolidaritesWebhooks
  class ProcessReferentAssignationJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if applicant.blank?
      return notify_agent_not_found if agent.blank?

      Applicant.with_advisory_lock "assigning_#{rdv_solidarites_agent_id}_to_#{rdv_solidarites_user_id}" do
        attach_agent_to_applicant if event == "created"
        remove_agent_from_applicant if event == "destroyed"
      end
    end

    private

    def event
      @meta[:event]
    end

    def rdv_solidarites_user_id
      @data[:user][:id]
    end

    def rdv_solidarites_agent_id
      @data[:agent][:id]
    end

    def applicant
      @applicant ||= Applicant.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
    end

    def agent
      @agent ||= Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_agent_id)
    end

    def notify_agent_not_found
      MattermostClient.send_to_notif_channel(
        "Referent not found for RDV-S referent assignation.\n" \
        "agent id: #{rdv_solidarites_agent_id}\n" \
        "user id: #{rdv_solidarites_user_id}"
      )
    end

    def attach_agent_to_applicant
      return if applicant.reload.agent_ids.include?(agent.id)

      applicant.agents << agent
    end

    def remove_agent_from_applicant
      return unless applicant.reload.agent_ids.include?(agent.id)

      applicant.agents.delete(agent)
    end
  end
end
