module RdvSolidaritesWebhooks
  class ProcessAgentRoleJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys
      return if organisation.blank?

      if event == "created"
        upsert_agent_and_raise if agent.nil?
        attach_agent_to_org
      end

      remove_from_org if agent && event == "destroyed"
    end

    private

    def event
      @meta[:event]
    end

    def rdv_solidarites_agent_id
      @data[:agent][:id]
    end

    def rdv_solidarites_organisation_id
      @data[:organisation][:id]
    end

    def upsert_agent_and_raise
      UpsertRecordJob.perform_async(
        "Agent",
        @data[:agent],
        { last_webhook_update_received_at: @meta[:timestamp] }
      )
      sleep 2

      raise(
        "Could not find agent #{rdv_solidarites_agent_id}. " \
        "Launched upsert agent job and will retry"
      )
    end

    def organisation
      @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
    end

    def agent
      @agent ||= Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_agent_id)
    end

    def attach_agent_to_org
      agent.organisations << organisation unless agent.organisation_ids.include?(organisation.id)
    end

    def remove_from_org
      agent.delete_organisation(organisation) if agent.organisation_ids.include?(organisation.id)
    end
  end
end
