module InboundWebhooks
  module RdvSolidarites
    class ProcessAgentJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        # email is blank for intervenant role
        return if @data[:email].blank?

        event == "destroyed" ? agent&.destroy! : upsert_agent
      end

      private

      def event
        @meta[:event]
      end

      def agent
        @agent ||= Agent.find_by(rdv_solidarites_agent_id: @data[:id])
      end

      def upsert_agent
        UpsertRecordJob.perform_later("Agent", @data, { last_webhook_update_received_at: @meta[:timestamp] })
      end
    end
  end
end
