module InboundWebhooks
  module RdvSolidarites
    class ProcessAgentJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        # email is blank for intervenant role
        return if @data[:email].blank?
        # agents are created by ProcessAgentRoleJob, along with their first role
        return if agent.blank?

        event == "destroyed" ? agent.destroy! : update_agent
      end

      private

      def event
        @meta[:event]
      end

      def agent
        @agent ||= Agent.find_by(rdv_solidarites_agent_id: @data[:id])
      end

      def update_agent
        call_service!(
          UpsertRecord,
          klass: Agent,
          rdv_solidarites_attributes: @data,
          additional_attributes: { last_webhook_update_received_at: @meta[:timestamp] }
        )
      end
    end
  end
end
