module InboundWebhooks
  module RdvSolidarites
    class ProcessAgentRoleJob < LockedAndOrderedJobBase
      def self.lock_key(data, _meta)
        "#{base_lock_key}:#{data.dig(:agent, :id)}:#{data.dig(:organisation, :id)}"
      end

      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        return if organisation.blank? || organisation.archived? || @data[:access_level] == "intervenant"

        if event == "destroyed"
          remove_agent_from_organisation
        elsif agent.blank?
          # the agent_role webhook can be received before the agent one
          self.class.perform_in(30.seconds, data, meta)
        else
          upsert_agent_role
        end
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

      def organisation
        @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
      end

      def agent
        @agent ||= Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_agent_id)
      end

      def agent_role
        @agent_role ||= AgentRole.find_by(agent:, organisation:)
      end

      def upsert_agent_role
        AgentRole.find_or_initialize_by(agent:, organisation:).update!(
          access_level: @data[:access_level],
          last_webhook_update_received_at: @meta[:timestamp]
        )
      end

      def remove_agent_from_organisation
        return if agent.blank?

        agent_role&.destroy!
        agent.destroy! if agent.reload.organisations.empty?
      end
    end
  end
end
