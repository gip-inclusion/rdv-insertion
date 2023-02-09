module RdvSolidaritesWebhooks
  class ProcessAgentJob < ApplicationJob
    def perform(data, meta)
      @data = data.deep_symbolize_keys
      @meta = meta.deep_symbolize_keys

      upsert_or_delete_agent
    end

    private

    def event
      @meta[:event]
    end

    def agent
      @agent = Agent.find_by(rdv_solidarites_agent_id: @data[:id])
    end

    def upsert_or_delete_agent
      return delete_agent if event == "destroyed"

      UpsertRecordJob.perform_async("Agent", @data, { last_webhook_update_received_at: @meta[:timestamp] })
    end

    def delete_agent
      agent.destroy!
    end
  end
end
