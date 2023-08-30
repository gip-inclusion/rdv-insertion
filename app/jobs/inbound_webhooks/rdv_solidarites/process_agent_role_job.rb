module InboundWebhooks
  module RdvSolidarites
    class ProcessAgentRoleJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if organisation.blank?

        assign_rdv_solidarites_agent_role_id if agent_role
        upsert_or_delete_agent_role
      end

      private

      def upsert_or_delete_agent_role
        return remove_agent_from_org if event == "destroyed"

        return upsert_agent_and_raise if agent.nil?

        upsert_agent_role
      end

      def remove_agent_from_org
        agent_role&.destroy! # we first destroy the agent role record
        return if agent.blank?

        # we ensure the agent is removed from the org in case agent role record wasn't found
        agent.organisations.delete(organisation)
        delete_agent if agent.reload.organisations.empty?
      end

      def delete_agent
        agent.destroy!
        MattermostClient.send_to_notif_channel "agent #{agent.rdv_solidarites_agent_id} destroyed"
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

      def upsert_agent_role
        UpsertRecordJob.perform_async(
          "AgentRole",
          @data,
          { organisation_id: organisation.id, agent_id: agent.id, last_webhook_update_received_at: @meta[:timestamp] }
        )
      end

      def assign_rdv_solidarites_agent_role_id
        agent_role.update!(rdv_solidarites_agent_role_id: @data[:id])
      end

      def event
        @meta[:event]
      end

      def rdv_solidarites_agent_role_id
        @data[:id]
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
        @agent_role ||= AgentRole.find_by(organisation_id: organisation.id, agent_id: agent&.id)
      end
    end
  end
end
