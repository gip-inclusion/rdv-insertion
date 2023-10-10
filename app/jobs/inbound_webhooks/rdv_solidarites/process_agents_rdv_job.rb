module InboundWebhooks
  module RdvSolidarites
    class ProcessAgentsRdvJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys

        return if rdv.blank? || agent.blank?

        if event == "destroyed"
          remove_agent_from_rdv
        else
          add_agent_to_rdv
        end
      end

      private

      def event
        @meta[:event]
      end

      def rdv_solidarites_rdv_id
        @data.dig(:rdv, :id)
      end

      def rdv_solidarites_agent_id
        @data.dig(:agent, :id)
      end

      def rdv
        @rdv ||= Rdv.find_by(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
      end

      def agent
        @agent ||= Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_agent_id)
      end

      def add_agent_to_rdv
        rdv.agents << agent unless rdv.reload.agent_ids.include?(agent.id)
      end

      def remove_agent_from_rdv
        rdv.agents.delete(agent)
      end
    end
  end
end
