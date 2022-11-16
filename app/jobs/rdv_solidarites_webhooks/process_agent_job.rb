module RdvSolidaritesWebhooks
  class ProcessAgentJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys

      # temporary step to assign rdv_solidarites_id to existing agents
      assign_rdv_solidarites_agent_id if agent
      upsert_or_delete_agent
    end

    private

    def event
      @meta[:event]
    end

    def assign_rdv_solidarites_agent_id
      agent.update!(rdv_solidarites_agent_id: @data[:id])
    end

    def agent
      @agent ||= Agent.find_by(email: @data[:email])
    end

    def upsert_or_delete_agent
      return delete_agent if event == "destroyed"

      UpsertRecordJob.perform_async("Agent", @data, { last_webhook_update_received_at: @meta[:timestamp] })
    end

    def delete_agent
      agent = Agent.find_by(rdv_solidarites_agent_id: @data[:id])
      agent.destroy!
    end
  end
end
